import { lazy } from 'react';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { Layout } from './components/AppLayout';
import { ToastProvider } from './components/Toast';

const DeckIndex = lazy(() => import('./pages/DeckIndex'));
const DeckDetail = lazy(() => import('./pages/DeckDetail'));
const MultiDeckStudySession = lazy(() => import('./pages/MultiDeckStudySession'));

const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    children: [
      { index: true, element: <DeckIndex /> },
      { path: 'deck/:deckId', element: <DeckDetail /> },
      { path: 'study', element: <MultiDeckStudySession /> },
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
