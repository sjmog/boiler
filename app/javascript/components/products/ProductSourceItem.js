import React, { useState } from "react";
import { Button } from "@/components/ui";
import { useProductSources } from '@/hooks/useProductSources';
import { DiffField } from "@/components";

export const ProductSourceItem = ({ source, product, onActionComplete }) => {
  const [replaceTitle, setReplaceTitle] = useState(!product.title);
  const [replaceDescription, setReplaceDescription] = useState(!product.description);
  const [replaceUrl, setReplaceUrl] = useState(!product.url);

  const { approveMutation, disapproveMutation } = useProductSources(product.id, true);

  const handleApprove = () => {
    approveMutation.mutate(
      { sourceId: source.id, productId: product.id, replaceOptions: { replaceTitle, replaceDescription, replaceUrl } },
      {
        onSuccess: () => {
          onActionComplete();
        }
      }
    );
  };

  const handleDisapprove = () => {
    disapproveMutation.mutate(
      { sourceId: source.id, productId: product.id },
      {
        onSuccess: () => {
          onActionComplete();
        }
      }
    );
  };

  return (
    <div className="mb-4 p-4 border rounded">
      <DiffField
        label="Title"
        currentValue={product.name}
        newValue={source.name}
        isReplacing={replaceTitle}
        onReplace={() => setReplaceTitle(!replaceTitle)}
      />
      <DiffField
        label="Description"
        currentValue={product.description}
        newValue={source.description}
        isReplacing={replaceDescription}
        onReplace={() => setReplaceDescription(!replaceDescription)}
      />
      <DiffField
        label="URL"
        className='truncate'
        currentValue={product.url}
        newValue={source.url}
        isReplacing={replaceUrl}
        onReplace={() => setReplaceUrl(!replaceUrl)}
      />
      <div className="mt-4 flex flex-wrap gap-2">
        <Button onClick={handleApprove} disabled={approveMutation.isLoading || disapproveMutation.isLoading}>
          {approveMutation.isLoading ? 'Approving...' : 'Approve as source'}
        </Button>
        <Button onClick={handleDisapprove} variant="destructive" disabled={approveMutation.isLoading || disapproveMutation.isLoading}>
          {disapproveMutation.isLoading ? 'Disapproving...' : 'Disapprove as source'}
        </Button>
      </div>
    </div>
  );
};