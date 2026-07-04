import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { Layout, DeckIndex } from './components/AppLayout';
import { DeckDetail } from './components/CardList';
import { StudySession } from './components/StudySession';
import { ToastProvider } from './components/Toast';

const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    children: [
      { index: true, element: <DeckIndex /> },
      { path: 'deck/:deckId', element: <DeckDetail /> },
      { path: 'deck/:deckId/study', element: <StudySession /> },
      { path: '*', element: <DeckIndex /> }
    ]
  }
]);

export default function App() {
  return (
    <ToastProvider>
      <RouterProvider router={router} />
    </ToastProvider>
  );
}
