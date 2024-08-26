import { useInfiniteQuery } from "react-query";
import { productApi } from "@/services/api";

export const useProductList = () => {
  return useInfiniteQuery(
    "products",
    ({ pageParam = 0 }) => productApi.fetchProducts(pageParam),
    {
      getNextPageParam: (lastPage, pages) => {
        return lastPage.length === 20 ? pages.length * 20 : undefined;
      },
    }
  );
};