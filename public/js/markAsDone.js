function markAsDone() {
  // Create the message element
  const message = document.createElement('div');
  message.textContent = '¡Completado!';
  message.style.position = 'fixed';
  message.style.top = '20px';
  message.style.right = '20px';
  message.style.backgroundColor = '#28a745';
  message.style.color = 'white';
  message.style.padding = '10px 20px';
  message.style.borderRadius = '5px';
  message.style.boxShadow = '0 2px 10px rgba(0,0,0,0.2)';
  message.style.zIndex = '1000';
  message.style.fontSize = '16px';
  message.style.fontWeight = 'bold';

  // Append to body
  document.body.appendChild(message);

  // Remove after 3 seconds
  setTimeout(() => {
    if (message.parentNode) {
      message.parentNode.removeChild(message);
    }
  }, 3000);
}