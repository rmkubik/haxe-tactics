function some<T>(func: (T) -> Bool, array:Array<T>): Bool {
  for (item in array) {
    if (func(item)) {
      return true;
    }
  }

  return false;
}

// This is unefficient O(n)^2, but I don't think we care
// Could probably figure out how to use a Set or Map to make it better
function removeDuplicates<T>(isEqual: (T, T) -> Bool, array:Array<T>): Array<T> {
  var noDupes:Array<T> = [];

  for (item in array) {
    if (!some((unDupedItem:T) -> isEqual(item, unDupedItem), noDupes)) {
      noDupes.push(item);
    }
  }

  return noDupes;
}