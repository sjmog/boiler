import React from "react";
import { createRoot } from "react-dom/client";
import { FlashToaster } from "@/components";

const renderFlash = () => {
  try {
    const flash = JSON.parse(
      document.getElementById("flash-toaster").dataset.flash
    );
    const rootElement = document.getElementById("flash-toaster");
    if (rootElement && flash) {
      const root = createRoot(rootElement);
      root.render(
        <React.StrictMode>
          <FlashToaster flash={flash} />
        </React.StrictMode>
      );
    }
  } catch (e) {
    console.error(e);
  }
};

const events = ["turbo:load", "DOMContentLoaded"];
const handleEvent = () => {
  renderFlash();
  events.forEach((e) => document.removeEventListener(e, handleEvent));
};
events.forEach((event) => document.addEventListener(event, handleEvent));
