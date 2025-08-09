const { useState } = React;

function WelcomeWidget() {
  const [count, setCount] = useState(0);
  return (
    React.createElement('div', { className: 'card' },
      React.createElement('h2', null, 'React in Schola Interlingua'),
      React.createElement('p', null, `Clics: ${count}`),
      React.createElement('button', { className: 'btn btn-primary', onClick: () => setCount(count + 1) }, 'Clicar')
    )
  );
}

const rootElement = document.getElementById('react-root');
if (rootElement) {
  const root = ReactDOM.createRoot(rootElement);
  root.render(React.createElement(WelcomeWidget));
}
