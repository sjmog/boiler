import { toast } from "@/components/ui/use-toast";
import { api } from "@/services";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";

const fetchUser = async () => {
  const { data } = await api.get("/api/v1/current_user");
  return data;
};

export const useSignOut = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: () => api.delete("/sign_out"),
    onSuccess: () => {
      window.currentUser = null;
      queryClient.setQueryData(["user"], null);
      queryClient.invalidateQueries({ queryKey: ["user"] });
      window.location.href = "/?toast=signed_out";
    },
    onError: (error) => {
      console.error(error);
    },
  });
};

export const useCurrentUser = () => {
  return useQuery({
    queryKey: ["user"],
    queryFn: fetchUser,
    initialData: window.currentUser,
    staleTime: 1000 * 60 * 5,
    retry: false,
  });
};
