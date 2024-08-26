import React from "react";
import { Checkbox } from "@/components/ui";
import { cn } from "@/lib/utils";

export const DiffField = ({
  label,
  currentValue,
  newValue,
  isReplacing,
  onReplace,
  ...props
}) => {
  const isDifferent = currentValue !== newValue;

  return (
    <div className="mb-2">
      <p className="font-semibold">{label}:</p>
      <p
        className={cn(
          isDifferent ? "line-through text-red-500" : "",
          props.className
        )}
      >
        {currentValue ?? "(no previous value)"}
      </p>
      {isDifferent && (
        <>
          <p className="text-green-500">{newValue}</p>
          <Checkbox
            checked={isReplacing}
            onCheckedChange={onReplace}
            label={`Replace ${label}`}
          />
        </>
      )}
    </div>
  );
};
