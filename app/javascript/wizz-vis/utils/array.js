/* jshint esversion: 6 */

export default {
  /**
   * Remove adjacent elements on the array that are equal
   * or has the same value on the key passed as argument
   * inside the object.
   *
   * @param {Object[]} input
   * @param {string} key
   * @returns {Object[]}
   */
  uniqueInOrder(input, key) {
    let result = [];
    for (let i = 0; i < input.length; i++) {
      const source = key ? input[i][key] : input[i];
      let dst;

      if (i == input.length - 1){
        dst = null;
      } else {
        dst = key ? input[i + 1][key] : input[i + 1];
      }

      if (JSON.stringify(source) != JSON.stringify(dst))
        result.push(input[i]);
    }

    return result;
  }
};