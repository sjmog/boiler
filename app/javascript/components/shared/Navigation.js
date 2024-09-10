import React from "react";
import { Link } from "react-router-dom";
import { useCurrentUser, useSignOut } from "@/services";

export const Navigation = () => {
  const { data: user, isLoading } = useCurrentUser();
  const signOut = useSignOut();

  const handleSignOut = async (e) => {
    e.preventDefault();
    signOut.mutate();
  };

  return (
    <nav className="bg-white shadow-sm border-b">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="h-16 relative">
          <div className="absolute left-1/2 top-1/2 w-[200px] -ml-[100px] h-[50px] -mt-[25px] flex items-center justify-center">
            <Link
              to="/"
              className="text-2xl text-center font-bold text-gray-800"
            >
              boiler
            </Link>
          </div>
          <div className="float-right h-16 flex items-center">
            {user ? (
              <>
                {user.isAdmin && <span className="mr-2">Admin</span>}
                <button
                  onClick={handleSignOut}
                  className="text-gray-600 hover:text-gray-900 ml-2"
                  disabled={signOut.isPending}
                >
                  {signOut.isPending ? "signing out..." : "sign out"}
                </button>
              </>
            ) : isLoading ? (
              <span>Loading...</span>
            ) : (
              <a
                href="/authenticate"
                className="text-gray-600 hover:text-gray-900"
              >
                sign in
              </a>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
};
