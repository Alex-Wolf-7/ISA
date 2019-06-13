import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.nio.charset.StandardCharsets;
import java.io.IOException;

/**
 * Assembler for Alex Wolf's ISA
 * Alexander Wolf, A12600211
 * CSE141L
 */
public class Assembler {
    BufferedReader in;
    FileOutputStream out;
    boolean prep = false;

    /**
     * Main, setup readers and call other methods
     */
    public static void main (String[] args) throws IOException {
        BufferedReader in = null;
        FileOutputStream out = null;

        if (args.length != 1) {
            System.err.println("Incorrect number of arguments, one input file name must be provided.");
            System.exit(1);
        } else if (!(args[0].endsWith(".al"))) {
            System.err.println("Input file must have \".al\" file extension.");
            System.exit(1);
        }

        try {
            in = new BufferedReader(new FileReader(new File(args[0])));
            out = new FileOutputStream("machine_code.alex");
            Assembler assembler = new Assembler(in, out);
            assembler.assemble();
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Error: unable to open file.");
        } finally {
            if (in != null) {
                in.close();
            }
            if (out != null) {
                out.close();
            }
        }
    }

    /**
     * Simple constructor
     */
    public Assembler (BufferedReader in, FileOutputStream out) {
        this.in = in;
        this.out = out;
    }

    /**
     * Do the actual work with the inputs
     */
    private void assemble () throws IOException {
	String line = "SLL $r0 $r0 0";
	line = sanitize(line);
	String error = parse(line);
	if (error != null) {
	    System.err.printf(error + "\n", -1);
	    System.exit(1);
	}

        int lineNum;
        for (lineNum = 1; (line = in.readLine()) != null; lineNum++) {
            line = sanitize(line);
            if (line == null) {
                continue;
            } else {
                error = parse(line);
                if (error != null) {
                    System.err.printf(error + "\n", lineNum);
                    System.exit(1);
                }
            }
        }
    }

    /**
     * Removes extra spaces and comments
     * @return null if useless line, sanitized line otherwise
     */
    private String sanitize (String line) {
        line.trim();
        line = removeComments(line);
        if (line.isEmpty()) {
            return null;
        } else {
            return line;
        }
    }

    /**
     * Removes comments
     */
    private String removeComments (String line) { 
        int hashpos = line.indexOf('#');
        if (hashpos == -1) {
            return line;
        }
        line = line.substring(0, hashpos);
        return line.trim();
    }

    /**
     * Does the actual work in turning the sanitized line into machine code and outputting it
     * @return error message if there is one, null if all good
     */
    private String parse (String line) throws IOException {
        String[] split = line.split("\\s+", 0);
        if (split.length <= 0) {
            return "Error on line %d: empty but not sanitized away.";
        } else {
            Pair<String, String> result;

            switch (split[0].trim()) {
                case ("PREP"): {
                    if (this.prep == true) return "Error on line %d: normal mode instruction during prep mode.";
                    this.prep = true;
                    result = oneLargeConstant(split, "000");
                    break;
                }
                case ("INC"): {
                    if (this.prep == true) return "Error on line %d: normal mode instruction during prep mode.";
                    split = Arrays.copyOf(split, split.length + 1);
                    split[split.length - 1] = "1";
                    result = twoRegConst(split, "001");
                    break;
                }
                case ("DEC"): {
                    if (this.prep == true) return "Error on line %d: normal mode instruction during prep mode.";
                    split = Arrays.copyOf(split, split.length + 1);
                    split[split.length - 1] = "0";
                    result = twoRegConst(split, "001");
                    break;
                }
                case ("XOR"): {
                    if (this.prep == true) return "Error on line %d: normal mode instruction during prep mode.";
                    result = threeReg(split, "010");
                    break;
                }
                case ("XORR"): {
                    if (this.prep == true) return "Error on line %d: normal mode instruction during prep mode.";
                    result = twoReg(split, "011");
                    break;
                }
                case ("SLL"): {
                    if (this.prep == true) return "Error on line %d: normal mode instruction during prep mode.";
                    result = twoRegConst(split, "100");
                    break;
                }
                case ("SRL"): {
                    if (this.prep == true) return "Error on line %d: normal mode instruction during prep mode.";
                    result = twoRegConst(split, "101");
                    break;
                }
                case ("END"): {
                    if (this.prep == true) return "Error on line %d: normal mode instruction during prep mode.";
                    result = endCommand(split, "111");
                    break;
                }

                case ("ANDI"): {
                    if (this.prep == false) return "Error on line %d: prep mode instruction during normal mode.";
                    this.prep = false;
                    result = twoRegPrep(split, "000");
                    break;
                }
                case ("BEQ"): {
                    if (this.prep == false) return "Error on line %d: prep mode instruction during normal mode.";
                    this.prep = false;
                    result = oneRegLast(split, "001");
                    break;
                }
                case ("LW"): {
                    if (this.prep == false) return "Error on line %d: prep mode instruction during normal mode.";
                    this.prep = false;
                    result = oneRegFirst(split, "010");
                    break;
                }
                case ("SW"): {
                    if (this.prep == false) return "Error on line %d: prep mode instruction during normal mode.";
                    this.prep = false;
                    result = oneRegLast(split, "011");
                    break;
                }
                case ("SAVE"): {
                    if (this.prep == false) return "Error on line %d: prep mode instruction during normal mode.";
                    this.prep = false;
                    result = oneRegFirst(split, "100");
                    break;
                }
                case ("PSFT"): {
                    if (this.prep == false) return "Error on line %d: prep mode instruction during normal mode.";
                    result = oneLargeConstant(split, "101");
                    break;
                }
                case ("PXOR"): {
                    if (this.prep == false) return "Error on line %d: prep mode instruction during normal mode.";
                    result = oneRegLast(split, "110");
                    break;
                }
                default: {
                    return "Error on line %d: instruction not recognized.";
                }
            }

            String error = result.getValue();
            if (error != null) return error;

            String machineCode = result.getKey();
            if (machineCode != null && machineCode.length() == 9) {
                out.write((machineCode + "\n").getBytes(StandardCharsets.UTF_8));
                return null;
            } else {
                return "Error on line %d: problem parsing into machine code.";
            }
        }
    }

    /**
     * Only the end command, no inputs
     * @return Pair, first String is Machine Code, second is any error
     */
    private Pair<String, String> endCommand (String[] split, String initialOpcode) {
        if (split.length < 1) {
            return new Pair<String, String>(null, "Error on line %d: too few arguments for end instruction.");
        } else if (split.length > 1) {
            return new Pair<String, String>(null, "Error on line %d: too many arguments for end instruction.");
        }

        // Success case
        return new Pair<String, String>(initialOpcode + "111111", null);
    }

    /**
     * Works for operations where the inputs are three registers
     * @return Pair, first String is Machine Code, second is any error
     */
    private Pair<String, String> oneLargeConstant (String[] split, String initialOpcode) {
        if (split.length < 2) {
            return new Pair<String, String>(null, "Error on line %d: too few arguments for prep instruction.");
        } else if (split.length > 2) {
            return new Pair<String, String>(null, "Error on line %d: too many arguments for prep instruction.");
        }

        try {
            String constant = largeConstToBinary(split[1]);
            // Success case
            return new Pair<String, String>(initialOpcode + constant, null);

        } catch (Exception e) {
            return new Pair<String, String>(null, "Error on line %d: constant cannot be parsed for prep instruction.");
        }
    }

    /**
     * Works for operations where the inputs are three registers
     * @return Pair, first String is Machine Code, second is any error
     */
    private Pair<String, String> threeReg (String[] split, String initialOpcode) {
        if (split.length < 4) {
            return new Pair<String, String>(null, "Error on line %d: too few arguments for threeReg instruction.");
        } else if (split.length > 4) {
            return new Pair<String, String>(null, "Error on line %d: too many arguments for threeReg instruction.");
        }

        try {
            String destinationReg = regToBinary(split[1]);
            String sourceReg1 = regToBinary(split[2]);
            String sourceReg2 = regToBinary(split[3]);
            // Success case
            return new Pair<String, String>(initialOpcode + destinationReg + sourceReg1 + sourceReg2, null);

        } catch (Exception e) {
            return new Pair<String, String>(null, "Error on line %d: register cannot be parsed for threeReg instruction.");
        }
    }

    /**
     * Works for operations where the inputs are two registers
     * @return Pair, first String is Machine Code, second is any error
     */
    private Pair<String, String> twoReg (String[] split, String initialOpcode) {
        if (split.length < 3) {
            return new Pair<String, String>(null, "Error on line %d: too few arguments for twoReg instruction.");
        } else if (split.length > 3) {
            return new Pair<String, String>(null, "Error on line %d: too many arguments for twoReg instruction.");
        }

        try {
            String destinationReg = regToBinary(split[1]);
            String sourceReg = regToBinary(split[2]);
            // Success case
            return new Pair<String, String>(initialOpcode + destinationReg + sourceReg + "00", null);

        } catch (Exception e) {
            return new Pair<String, String>(null, "Error on line %d: register cannot be parsed for twoReg instruction.");
        }
    }

    /**
     * Works for operations where the input is one register and prep is used
     * @return Pair, first String is Machine Code, second is any error
     */
    private Pair<String, String> oneRegLast (String[] split, String initialOpcode) {
        if (split.length < 2) {
            return new Pair<String, String>(null, "Error on line %d: too few arguments for oneRegLast instruction.");
        } else if (split.length > 2) {
            return new Pair<String, String>(null, "Error on line %d: too many arguments for oneRegLast instruction.");
        }

        try {
            String sourceReg = regToBinary(split[1]);
            // Success case
            return new Pair<String, String>(initialOpcode + "00" + "00" + sourceReg, null);

        } catch (Exception e) {
            return new Pair<String, String>(null, "Error on line %d: register cannot be parsed for oneRegLast instruction.");
        }
    }

    /**
     * Works for operations where the input is one register and prep is used
     * @return Pair, first String is Machine Code, second is any error
     */
    private Pair<String, String> oneRegFirst (String[] split, String initialOpcode) {
        if (split.length < 2) {
            return new Pair<String, String>(null, "Error on line %d: too few arguments for oneRegFirst instruction.");
        } else if (split.length > 2) {
            return new Pair<String, String>(null, "Error on line %d: too many arguments for oneRegFirst instruction.");
        }

        try {
            String sourceReg = regToBinary(split[1]);
            // Success case
            return new Pair<String, String>(initialOpcode + sourceReg + "00" + "00", null);

        } catch (Exception e) {
            return new Pair<String, String>(null, "Error on line %d: register cannot be parsed for oneRegFirst instruction.");
        }
    }

    /**
     * Works for operations where the inputs are two registers, but uses prep
     * @return Pair, first String is Machine Code, second is any error
     */
    private Pair<String, String> twoRegPrep (String[] split, String initialOpcode) {
        if (split.length < 3) {
            return new Pair<String, String>(null, "Error on line %d: too few arguments for twoRegPrep instruction.");
        } else if (split.length > 3) {
            return new Pair<String, String>(null, "Error on line %d: too many arguments for twoRegPrep instruction.");
        }

        try {
            String destinationReg = regToBinary(split[1]);
            String sourceReg = regToBinary(split[2]);
            // Success case
            return new Pair<String, String>(initialOpcode + destinationReg + "00" + sourceReg, null);

        } catch (Exception e) {
            return new Pair<String, String>(null, "Error on line %d: register cannot be parsed for twoRegPrep instruction.");
        }
    }

    /**
     * Works for operations where the inputs are two registers
     * @return Pair, first String is Machine Code, second is any error
     */
    private Pair<String, String> twoRegConst (String[] split, String initialOpcode) {
        if (split.length < 4) {
            return new Pair<String, String>(null, "Error on line %d: too few arguments for twoRegConst instruction.");
        } else if (split.length > 4) {
            return new Pair<String, String>(null, "Error on line %d: too many arguments for twoRegConst instruction.");
        }

        try {
            String destinationReg = regToBinary(split[1]);
            String sourceReg = regToBinary(split[2]);
            String constant = smallConstToBinary(split[3]); 
            // Success case
            return new Pair<String, String>(initialOpcode + destinationReg + sourceReg + constant, null);

        } catch (Exception e) {
            return new Pair<String, String>(null,
                    "Error on line %d: register or constant cannot be parsed for twoRegConst instruction.");
        }
    }

    private String largeConstToBinary (String constant) throws Exception {
        constant = constant.trim();
        if (constant.length() != 6) {
            throw new Exception();
        } else if (!constant.matches("[01]+")) {
            throw new Exception();
        }
        return constant;
    }

    private String regToBinary (String register) throws Exception {
        switch (register.trim()) {
            case ("$r0"):
            case ("$r0,"): {
                return "00";
            }
            case ("$r1"):
            case ("$r1,"): {
                return "01";
            }
            case ("$r2"):
            case ("$r2,"): {
                return "10";
            }
            case ("$r3"):
            case ("$r3,"): {
                return "11";
            }
            default: {
                throw new Exception();
            }
        }
    }

    private String smallConstToBinary (String constant) throws Exception {
        switch (constant.trim()) {
            case ("0"): {
                return "00";
            }
            case ("1"): {
                return "01";
            }
            case ("2"): {
                return "10";
            }
            case ("3"): {
                return "11";
            }
            default: {
                throw new Exception();
            }
        }
    }

    class Pair<S, T> {
        private S key;
	private T value;

	public Pair (S key, T value) {
	    this.key = key;
	    this.value = value;
	}

	public S getKey () {
	    return key;
	}

	public T getValue () {
	    return value;
	}
    }
}
