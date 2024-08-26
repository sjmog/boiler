import React from 'react';

export const AdminContext = React.createContext(false);

export const AdminProvider = ({ children }) => {
  const isAdmin = window.currentUser?.isAdmin || false;

  return (
    <AdminContext.Provider value={isAdmin}>
      {children}
    </AdminContext.Provider>
  );
};