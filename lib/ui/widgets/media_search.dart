import 'dart:convert';

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/models.dart';
import '../../services/commons_api.dart';
import '../../services/languages.dart';
import '../../services/media_download.dart';
import '../../services/audio_service.dart' as audio;
import 'attachment_views.dart';

/// Commons media search + local file upload + reorderable tray, used by
/// the card editor for both pronunciation (audio) and image sides.
class MediaSearch extends StatefulWidget {
  final AttachmentType type;
  final Language? defaultLanguage;
  final String? autoQuery;
  final List<CardAttachment> selected;
  final ValueChanged<List<CardAttachment>> onChange;

  const MediaSearch({
    super.key,
    required this.type,
    this.defaultLanguage,
    this.autoQuery,
    required this.selected,
    required this.onChange,
  });

  @override
  State<MediaSearch> createState() => _MediaSearchState();
}

class _MediaSearchState extends State<MediaSearch> {
  Language? _language;
  final _query = TextEditingController();
  bool _loading = false;
  List<CommonsMedium> _results = const [];
  final Set<String> _downloading = {};
  String? _appliedAutoQuery;
  int _searchSeq = 0;

  @override
  void initState() {
    super.initState();
    _language = widget.defaultLanguage;
    _applyAutoQuery();
  }

  @override
  void didUpdateWidget(covariant MediaSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultLanguage != oldWidget.defaultLanguage) {
      _language = widget.defaultLanguage;
    }
    _applyAutoQuery();
  }

  void _applyAutoQuery() {
    final parts = _prepareQuery(widget.autoQuery);
    if (parts == null) return;
    final q = parts.join(', ');
    if (q == _appliedAutoQuery) return;
    _appliedAutoQuery = q;
    _query.text = q;
    if (widget.type == AttachmentType.image || _language != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _runSearch();
      });
    }
  }

  List<String>? _prepareQuery(String? raw) {
    if (raw == null) return null;
    final parts = raw
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts;
  }

  Future<void> _upload() async {
    final files = await FilePicker.pickFiles(
      type: widget.type == AttachmentType.image
          ? FileType.image
          : FileType.audio,
    );
    if (files.isEmpty) return;
    final next = [...widget.selected];
    for (final file in files) {
      final Uint8List bytes;
      try {
        bytes = await file.readAsBytes();
      } catch (_) {
        continue;
      }
      final data = base64Encode(bytes);
      if (next.any((s) => base64Encode(s.content) == data)) continue;
      next.add(CardAttachment(
        type: widget.type,
        mimeType: mimeFromFileName(file.name),
        content: bytes,
        caption: file.name.replaceFirst(RegExp(r'\.[^.]+$'), ''),
        attribution: null,
        languageQid: null,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    widget.onChange(next);
  }

  Future<void> _runSearch() async {
    final parts = _prepareQuery(_query.text);
    if (parts == null) return;
    if (widget.type == AttachmentType.audio && _language == null) return;
    final seq = ++_searchSeq;
    setState(() {
      _loading = true;
      _results = const [];
    });
    try {
      final groups = await Future.wait(parts.map(_searchMedia));
      if (seq != _searchSeq) return;
      final results = ResultList(widget.type, _interleave(groups));
      setState(() => _results = results.clean().results);
    } catch (e) {
      if (seq != _searchSeq) return;
      setState(() => _results = const []);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load media: $e')),
        );
      }
    } finally {
      if (seq == _searchSeq && mounted) setState(() => _loading = false);
    }
  }

  Future<List<CommonsMedium>> _searchMedia(String q) =>
      widget.type == AttachmentType.image
          ? searchCommonsImages(q, limit: 10)
          : searchCommonsAudio(q, _language!, limit: 10);

  List<CommonsMedium> _interleave(List<List<CommonsMedium>> groups) {
    final longest = groups.fold(
        0, (n, g) => g.length > n ? g.length : n);
    return [
      for (var i = 0; i < longest; i++)
        for (final group in groups)
          if (i < group.length) group[i],
    ];
  }

  /// Commons picks are downloaded immediately: attachments are always
  /// stored in the database, never kept as remote urls.
  Future<void> _toggle(CommonsMedium m) async {
    if (widget.type == AttachmentType.audio) {
      audio.playAudio(m.url);
    }
    final caption = captionFromTitle(m.title, widget.type);
    final selected = widget.selected
        .where((s) => s.type == widget.type && s.caption == caption)
        .toList();
    if (selected.isNotEmpty) {
      widget.onChange(widget.selected.where((s) => s != selected.first).toList());
      return;
    }
    if (_downloading.contains(m.url)) return;
    setState(() => _downloading.add(m.url));
    try {
      final media = await downloadMedia(m.url);
      widget.onChange([
        ...widget.selected,
        CardAttachment(
          type: widget.type,
          mimeType: media.mimeType,
          content: media.bytes,
          caption: caption,
          attribution: attributionOf(m),
          languageQid:
              widget.type == AttachmentType.audio ? _language?.qid : null,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not download ${widget.type.name}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading.remove(m.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioType = widget.type == AttachmentType.audio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (audioType)
          DropdownButton<Language?>(
            value: _language,
            isExpanded: true,
            hint: const Text('No language'),
            items: [
              const DropdownMenuItem(value: null, child: Text('No language')),
              for (final l in kLanguages)
                DropdownMenuItem(value: l, child: Text(l.label)),
            ],
            onChanged: (v) => setState(() => _language = v),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _query,
                enabled: !audioType || _language != null,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  hintText: 'Search ${widget.type.name}',
                ),
                onSubmitted: (_) => _runSearch(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: (!audioType || _language != null) && !_loading
                  ? _runSearch
                  : null,
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Search'),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: _upload,
          icon: const Icon(Icons.upload_file, size: 16),
          label: Text('Upload your own ${widget.type.name}'),
        ),
        if (_results.isNotEmpty)
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _results.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final m = _results[i];
                final caption = captionFromTitle(m.title, widget.type);
                final selected = widget.selected
                    .any((s) => s.type == widget.type && s.caption == caption);
                final downloading = _downloading.contains(m.url);
                return SizedBox(
                  width: 130,
                  child: InkWell(
                    onTap: downloading ? null : () => _toggle(m),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Expanded(
                            child: downloading
                                ? const Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  )
                                : widget.type == AttachmentType.image
                                    ? Image.network(
                                        m.url,
                                        headers: {
                                          'User-Agent': commonsUserAgent,
                                        },
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            const Icon(Icons.broken_image),
                                      )
                                    : const Icon(Icons.volume_up_outlined),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            attributionOf(m),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 9,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        AttachmentTray(
          items: widget.selected,
          onChange: widget.onChange,
        ),
      ],
    );
  }
}

class ResultList {
  final AttachmentType type;
  final List<CommonsMedium> results;

  const ResultList(this.type, this.results);

  ResultList clean() {
    final urls = <String>{};
    final titles = <String, int>{};
    final cleaned = <CommonsMedium>[];
    for (final m in results) {
      if (!urls.add(m.url)) continue;
      if (type == AttachmentType.audio) {
        final key = normalizeCommonsTitle(m.title);
        final i = titles[key];
        if (i != null) {
          if (m.title.contains('LL-Q') &&
              !cleaned[i].title.contains('LL-Q')) {
            cleaned[i] = m;
          }
          continue;
        }
        titles[key] = cleaned.length;
      }
      cleaned.add(m);
    }
    return ResultList(type, cleaned);
  }
}

/// The selected attachments, reorderable, with remove buttons.
class AttachmentTray extends StatelessWidget {
  final List<CardAttachment> items;
  final ValueChanged<List<CardAttachment>> onChange;

  const AttachmentTray({
    super.key,
    required this.items,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: items.length,
      onReorderItem: (oldIndex, newIndex) {
        final next = [...items];
        final item = next.removeAt(oldIndex);
        next.insert(newIndex, item);
        onChange(next);
      },
      itemBuilder: (context, i) {
        final item = items[i];
        return ListTile(
          key: ValueKey('${item.createdAt}-${item.content.length}-$i'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          leading: ReorderableDragStartListener(
            index: i,
            child: item.type == AttachmentType.image
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AttachmentImage(
                      attachment: item,
                      width: 48,
                      height: 48,
                    ),
                  )
                : const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.volume_up_outlined),
                  ),
          ),
          title: Text(
            item.caption.isEmpty ? item.type.name : item.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          subtitle: (item.attribution ?? '').isEmpty
              ? null
              : Text(
                  item.attribution!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.type == AttachmentType.audio)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.play_arrow, size: 20),
                  onPressed: () => audio.playAudio(item.dataUrl),
                ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => onChange(
                    [for (final (j, x) in items.indexed) if (j != i) x]),
              ),
            ],
          ),
        );
      },
    );
  }
}
