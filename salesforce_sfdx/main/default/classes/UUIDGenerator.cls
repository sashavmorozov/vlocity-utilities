public class UUIDGenerator {
    /**
     * Generates a unique UUID version 4.
     * 
     * @return A string representing a UUID version 4.
     */
    public static String generateUUIDv4() {
        String chars = '0123456789abcdef';
        
        // Generate the first 8 characters
        String uuid = generateRandomHexString(chars, 8) + '-';
        
        // Generate the next 4 characters
        uuid += generateRandomHexString(chars, 4) + '-';
        
        // Generate the next 4 characters, starting with '4' (version 4 UUID)
        uuid += '4' + generateRandomHexString(chars, 3) + '-';
        
        // Generate the next 4 characters, ensuring it starts with '8', '9', 'a', or 'b'
        uuid += generateRandomHexChar(chars, '89ab') + generateRandomHexString(chars, 3) + '-';
        
        // Generate the final 12 characters
        uuid += generateRandomHexString(chars, 12);
        
        return uuid;
    }
    
    /**
     * Generates a random hex string of a given length.
     * 
     * @param chars The characters to choose from.
     * @param length The length of the resulting string.
     * @return A string of random hex characters.
     */
    private static String generateRandomHexString(String chars, Integer length) {
        String result = '';
        for (Integer i = 0; i < length; i++) {
            Integer randIndex = Math.floor(Math.random() * chars.length()).intValue();
            result += chars.substring(randIndex, randIndex + 1);
        }
        return result;
    }
    
    /**
     * Generates a single random hex character from a given string of options.
     * 
     * @param chars The characters to choose from.
     * @param options The specific characters allowed (e.g., '89ab').
     * @return A single random hex character.
     */
    private static String generateRandomHexChar(String chars, String options) {
        Integer randIndex = Math.floor(Math.random() * options.length()).intValue();
        return options.substring(randIndex, randIndex + 1);
    }
}
