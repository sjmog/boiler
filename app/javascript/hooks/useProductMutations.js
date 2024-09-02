import { useMutation, useQueryClient } from "react-query";
import { toast } from "@/components/ui/use-toast";
import { productApi } from "@/services/api";

// example useProductMutations, pairs with @/services/api/productApi
export const useProductMutations = () => {
  const queryClient = useQueryClient();

  const createMutation = (mutationFn, successMessage) => 
    useMutation(mutationFn, {
      onSuccess: () => {
        queryClient.invalidateQueries("products");
        toast({
          title: "Success",
          description: successMessage,
        });
      },
    });

  const deleteMutation = createMutation(productApi.deleteProduct, "Product deleted successfully");
  const restoreMutation = createMutation(productApi.restoreProduct, "Product restored successfully");
  const validateMutation = createMutation(productApi.validateProduct, "Product validated successfully");

  return {
    deleteMutation,
    restoreMutation,
    validateMutation,
  };
};