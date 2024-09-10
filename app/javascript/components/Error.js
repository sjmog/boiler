import React from "react";
import { useRouteError } from "react-router-dom";

export const Error = () => {
  const error = useRouteError();
  console.error(error);

  return (
    <div className="h-screen bg-white flex flex-col items-center justify-center">
      <div className="max-w-xl w-full px-4 text-center">
        <h1 className="text-6xl font-bold text-gray-900 mb-4">Oops!</h1>
        <p className="text-xl text-gray-600 mb-8">Sorry, an unexpected error has occurred.</p>
        <p className="text-lg text-gray-500 italic">
          {error.statusText || error.message}
        </p>
      </div>
    </div>
  );
}
