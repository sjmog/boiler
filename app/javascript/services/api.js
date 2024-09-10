import React from "react";
import axios from "axios";
import { toast } from "@/components/ui/use-toast";

const getCsrfToken = () =>
  document.querySelector('meta[name="csrf-token"]').getAttribute("content");

const handleApiError = async (error) => {
  let errorMessage = "An error occurred";
  let errorDetails = "";

  if (error.response) {
    errorMessage = error.response.statusText;
    try {
      errorDetails = error.response.data;
    } catch (e) {
      errorDetails = "Could not fetch error details";
    }
  } else if (error.request) {
    errorMessage = "No response received from server";
  } else {
    errorMessage = error.message;
  }

  toast({
    title: "Error",
    description: (
      <div>
        {errorMessage}
        <button
          onClick={() => alert(JSON.stringify(errorDetails))}
          className="ml-2 underline"
        >
          View Details
        </button>
      </div>
    ),
    variant: "destructive",
  });

  throw error; // Re-throw the error so it can be caught by React Query
};

export const api = axios.create({
  headers: {
    Accept: "application/json",
    "Content-Type": "application/json",
    "X-CSRF-Token": getCsrfToken(),
  },
});

// Add a response interceptor
api.interceptors.response.use(
  (response) => response,
  (error) => handleApiError(error)
);
