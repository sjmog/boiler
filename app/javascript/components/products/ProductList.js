import React from "react";
import { Product } from "@/components";
import InfiniteScroll from "react-infinite-scroll-component";
import { useProductList } from '@/hooks/useProductList';

export const ProductList = () => {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isLoading,
    isError,
    error
  } = useProductList();

  if (isLoading) return <div>Loading...</div>;
  if (isError) return <div>Error: {error.message}</div>;

  const products = data?.pages.flatMap(page => page) || [];

  return (
    <div className="container mx-auto px-4">
      <InfiniteScroll
        dataLength={products.length}
        next={fetchNextPage}
        hasMore={hasNextPage}
        loader={<h4>Loading...</h4>}
        endMessage={<p>No more products to load.</p>}
      >
        {products.map((product) => (
          <Product 
            key={product.id} 
            product={product}
          />
        ))}
      </InfiniteScroll>
    </div>
  );
};