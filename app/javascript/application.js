import React from "react";
import { createRoot } from "react-dom/client";
import { Root, Error } from "@/components";
import { Home, App } from "@/pages";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import "@hotwired/turbo-rails";
import { createConsumer } from "@rails/actioncable";

// Setup Action Cable
window.App = window.App || {};
App.cable = createConsumer();

const routes = [
  {
    path: "/",
    element: <Root />,
    errorElement: <Error />,
    children: [
      {
        index: true,
        element: <Home />,
      },
      {
        path: "app",
        element: <App />,
      },
    ],
  },
];

const router = createBrowserRouter(routes);

const renderApp = () => {
  const rootElement = document.getElementById("root");
  if (rootElement) {
    const root = createRoot(rootElement);
    root.render(<RouterProvider router={router} />);
  }
};

const events = ["turbo:load", "DOMContentLoaded"];
const handleEvent = () => {
  renderApp();
  events.forEach((e) => document.removeEventListener(e, handleEvent));
};
events.forEach((event) => document.addEventListener(event, handleEvent));
