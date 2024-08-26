import React from 'react';
import { QueryClient, QueryClientProvider } from 'react-query';
import { AdminProvider } from '@/contexts';
import { ProductList } from '@/components';
import { Toaster } from "@/components/ui";

const queryClient = new QueryClient();

export const App = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <AdminProvider>
        <main>
          <div className='max-w-screen mx-auto p-8 bg-gray-50'>
            <ProductList />
          </div>
          <Toaster />
        </main>
      </AdminProvider>
    </QueryClientProvider>
  );
};