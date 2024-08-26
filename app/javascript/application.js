import React from 'react'
import { createRoot } from 'react-dom/client'
import { App } from './components';
import '@hotwired/turbo-rails'
import { createConsumer } from '@rails/actioncable'

// Setup Action Cable
window.App = window.App || {};
App.cable = createConsumer();

const renderApp = () => {
  const rootElement = document.getElementById('root')
  if (rootElement) {
    const root = createRoot(rootElement)
    root.render(
      <React.StrictMode>
        <App />
      </React.StrictMode>
    )
  }
}

document.addEventListener('turbo:load', renderApp)
document.addEventListener('DOMContentLoaded', renderApp)