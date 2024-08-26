import React, { useContext, useState } from "react";
import {
  Button,
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  CardFooter,
} from "@/components/ui";
import { AdminContext } from "@/contexts";
import { ProductSourcesModal } from "@/components";
import {
  FaBook,
  FaReddit,
  FaTrash,
  FaUndo,
  FaCheck,
  FaExternalLinkAlt,
} from "react-icons/fa";
import { useProductMutations } from "@/hooks";
import { displayUrl } from "@/lib/utils";

export const Product = ({ product }) => {
  const isAdmin = useContext(AdminContext);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const { deleteMutation, restoreMutation, validateMutation } =
    useProductMutations();

  const formatDate = (dateString) => {
    const options = { year: "numeric", month: "long", day: "numeric" };
    return new Date(dateString).toLocaleDateString(undefined, options);
  };

  const mainSource = product.sources && product.sources[0];

  const handleDelete = () => {
    deleteMutation.mutate(product.id);
  };

  const handleRestore = () => {
    restoreMutation.mutate(product.id);
  };

  const handleValidate = () => {
    validateMutation.mutate(product.id);
  };

  return (
    <Card className="mb-4">
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle>{product.name}</CardTitle>
          <a
            href={product.url}
            target="_blank"
            rel="noopener noreferrer"
            className="text-xs text-blue-500 hover:text-blue-700 hover:underline flex items-center truncate"
          >
            <FaExternalLinkAlt className="mr-1" />
            {displayUrl(product.url)}
          </a>
        </div>
        {mainSource && (
          <div className="mt-2 text-sm text-gray-600">
            <span className="flex items-center">
              {mainSource.source === "reddit" && (
                <>
                  <FaReddit className="mr-1" />
                  r/{mainSource.meta.subreddit}
                </>
              )}
              {mainSource.meta.created_utc && (
                <span className="ml-2">
                  Posted on {formatDate(mainSource.meta.created_utc * 1000)}
                </span>
              )}
              <span
                className={`ml-2 px-2 py-1 rounded-full text-xs ${
                  product.validated
                    ? "bg-green-100 text-green-800"
                    : "bg-yellow-100 text-yellow-800"
                }`}
              >
                {product.validated ? "Approved" : "Pending"}
              </span>
            </span>
          </div>
        )}
        {product.description && (
          <CardDescription>{product.description}</CardDescription>
        )}
      </CardHeader>
      <CardContent>
        {product.buzz && (
          <span className="bg-green-100 text-green-800 px-2 py-1 rounded-full text-sm mr-2">
            Buzz: {product.buzz}
          </span>
        )}
        {product.tags && product.tags.length > 0 && (
          <div className="mt-2">
            {product.tags.map((tag, index) => (
              <span
                key={index}
                className="bg-gray-200 text-gray-700 px-2 py-1 rounded-full text-sm mr-2"
              >
                {tag.name}
              </span>
            ))}
          </div>
        )}
      </CardContent>
      <CardFooter className="flex justify-end">
        {isAdmin && (
          <div>
            <Button onClick={() => setIsModalOpen(true)} className="mr-2">
              <FaBook className="mr-1" />{" "}
              {product.sources ? product.sources.length : 0}
            </Button>
            <Button
              onClick={handleDelete}
              variant="destructive"
              className="mr-2"
            >
              <FaTrash />
            </Button>
            {product.deleted && (
              <Button
                onClick={handleRestore}
                variant="secondary"
                className="mr-2"
              >
                <FaUndo />
              </Button>
            )}
            {!product.validated && (
              <Button onClick={handleValidate} variant="outline">
                <FaCheck className="mr-1" />
              </Button>
            )}
          </div>
        )}
      </CardFooter>
      {isAdmin && (
        <ProductSourcesModal
          open={isModalOpen}
          product={product}
          onClose={() => setIsModalOpen(false)}
        />
      )}
    </Card>
  );
};
