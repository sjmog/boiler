import React from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui";
import { ProductSourceItem } from "./ProductSourceItem";
import { useProductSources } from '@/hooks/useProductSources';

export const ProductSourcesModal = ({ product, onClose, open }) => {
  const { sourcesQuery } = useProductSources(product.id, open);

  const handleActionComplete = () => {
    sourcesQuery.refetch();
    onClose();
  };

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="max-h-[80vh] overflow-hidden flex flex-col">
        <DialogHeader>
          <DialogTitle>Manage Product Sources</DialogTitle>
        </DialogHeader>
        <div className="flex-grow overflow-y-auto">
          {sourcesQuery.isLoading ? (
            <p>Loading...</p>
          ) : (
            sourcesQuery.data?.map((source) => (
              <ProductSourceItem
                key={source.id}
                source={source}
                product={product}
                onActionComplete={handleActionComplete}
              />
            ))
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
};