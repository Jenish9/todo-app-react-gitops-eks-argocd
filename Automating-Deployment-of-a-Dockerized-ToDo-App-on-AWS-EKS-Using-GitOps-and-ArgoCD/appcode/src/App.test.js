import { render, screen } from '@testing-library/react';
import App from './App';

test('renders todo title', () => {
  render(<App />);
  const titleElement = screen.getByText(/todo list/i);
  expect(titleElement).toBeInTheDocument();
});