import React, { useEffect, useMemo } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Outlet } from "react-router-dom";
import { Navigation } from "@/components";
import { Toaster, useToast } from "@/components/ui";

const queryClient = new QueryClient();

export const Root = () => {
  const { toast } = useToast();

  const flash = useMemo(() => {
    const flashElement = document.querySelector('meta[name="flash-messages"]');

    if (flashElement) {
      content = JSON.parse(flashElement.content);
      flashElement.remove();
      return content;
    }

    return {};
  }, []);

  const [searchParams] = useMemo(() => {
    if (typeof window !== 'undefined') {
      return [new URLSearchParams(window.location.search)];
    }
    return [new URLSearchParams()];
  }, []);

  useEffect(() => {
    if (searchParams.get('toast') === 'signed_out') {
      toast({
        title: 'Signed Out',
        description: 'You have been successfully signed out.',
        variant: 'default',
      });
      
      // Remove the 'toast' parameter from the URL
      searchParams.delete('toast');
      const newUrl = window.location.pathname + (searchParams.toString() ? '?' + searchParams.toString() : '');
      window.history.replaceState({}, '', newUrl);
    }
  }, [searchParams, toast]);

  useEffect(() => {
    Object.entries(flash).forEach(([type, message]) => {
      toast({
        title: type.charAt(0).toUpperCase() + type.slice(1),
        description: message,
        variant: type === "alert" ? "destructive" : "default",
      });
    });
  }, [flash]);

  return (
    <QueryClientProvider client={queryClient}>
      <Navigation />
      <main>
        <div className="max-w-screen h-[calc(100vh-65px)] mx-auto p-8 bg-gray-50">
          <Outlet />
        </div>
        <Toaster />
      </main>
    </QueryClientProvider>
  );
};
