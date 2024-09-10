import React, { useEffect } from "react";
import { Toaster, useToast } from "@/components/ui";

export const FlashToaster = ({ flash }) => {
  const { toast } = useToast();

  useEffect(() => {
    Object.entries(flash).forEach(([type, message]) => {
      toast({
        title: type.charAt(0).toUpperCase() + type.slice(1),
        description: message,
        variant: type === "alert" ? "destructive" : "default",
      });
    });
  }, [flash]);

  return <Toaster />;
};
