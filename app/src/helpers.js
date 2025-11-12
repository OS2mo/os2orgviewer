function convertToArray(string) {
  if (!string) return [] // <-- return empty array
  return string.replace(/['"[\]\ ]/g, "").split(",")
}

function convertToBoolean(string) {
  // Takes a string and transforms it to a Boolean
  return string === "true"
}

export { convertToArray, convertToBoolean }
