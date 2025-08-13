const { useState, useEffect } = React;

function ThemeToggle() {
  const [theme, setTheme] = useState(() => localStorage.getItem('theme') || 'light');

  useEffect(() => {
    document.body.dataset.theme = theme;
    localStorage.setItem('theme', theme);
  }, [theme]);

  const toggle = () => setTheme(theme === 'light' ? 'dark' : 'light');

  return (
    <button className="btn btn-primary" onClick={toggle}>
      {theme === 'light' ? 'Modo oscuro' : 'Modo claro'}
    </button>
  );
}

ReactDOM.createRoot(document.getElementById('react-root')).render(<ThemeToggle />);
