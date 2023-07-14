# TCL_programming
Tcl (Tool Command Language) is a scripting language that provides a simple yet powerful way to automate tasks, create GUI applications, and develop various software solutions. It is widely used in the software industry for its ease of use, flexibility, and extensibility.
 

# Objective:

BUILD A USER INTERFACE WHICH WILL TAKE A EXCEL SHEET(.csv FILE) AS INPUT AND GET THE DATA SHEET(TIMING RESULTS) AS OUTPUT, USING VARIOUS OPENSOURCE SYNTHESIS TOOL SUCH AS YOSYS ETC...

# Subtask:
1.) Create command {for eg. vsdsynth} and pass .csv fle(openMSP430_design_details.csv) from unix shell to tcl script

2.)convert all input to format[1] and .SDC format and pass to synthesis tool "yosys".
format[1] which is need for the synthesis tool 'yosys'.
sdc format :used for converting the constraints to sdc format.

2.) convert format[1] and sdc format into format[2] and pass to the timing tool 'opentimer'(used to create data sheet)similar to STA ENGINE.

# TASK 1:
> Create command {for eg. vsdsynth} and pass .csv fle from unix shell to tcl script
----------------------------------------------------------------------------------------------------------------------
Considering some general scenerios from user point of view

1.)
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/3e6fb8c4-24c9-4068-a1ee-7e36e7f19ba1)
                                Not provide .csv file as input

2.)
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/b3b08524-5661-44ad-b02c-7ebe4e48bd9e)
                            provided a .csv file which donot exist

3.)
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/afc0ca06-f6e2-4c01-9c0c-98e03b8a1690)
                                   typed "help" to find out usage

# Task 2
# > convert all input to format[1] and .SDC format and pass to synthesis tool "yosys".format[1] which is need for the synthesis tool 'yosys'.

# Subtask (A):
a) Creating the variables for the same name as mentioned in the user provided (.csv) file.

b) checking for existance of the files and directories at the location provided in the .csv file

# Input .csv file
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/f4e6761b-be81-46a7-924c-8ee1250c0db6)


# Scripts
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/168b8eaa-08eb-4c12-ba16-8837ac8ba5b2)
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/cf02c6bc-4cd8-42b9-8630-687885fe3582)
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/38ab50b3-007a-4ca9-814f-96e1edfb53af)

# Result:
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/763a80b5-d22a-450c-b7a2-dce893ae9cb6)

# Subtask (B):
# > Computing the initial location of the "clock" , "Input_ports" and "Output_ports" for creating the .sdc format file which will be used for synthesis.

# Input .csv file with clock constriants
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/501d12c6-9554-4374-a89d-2cc54bb1ae11)

# Scripts
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/0a9a8262-b387-4708-972a-4e4d08ab0433)

# Result :
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/fa73cc96-6855-4544-bc0f-af2e951a6f4d)

# Subtask (C)
# > Representation of the Clock-Contraints from the input .csv file in a format suitable for dumping the into the .sdc file used for synthesis 

# Input .csv file with input constriants
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/501d12c6-9554-4374-a89d-2cc54bb1ae11)

# scripts
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/40001756-0dbe-4c5c-893f-d63a341c666e)

# Result :
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/cdd1f2f3-45b8-4a4c-8bbd-71bd3d41bf51)

>format suitable for dumping the into .sdc file
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/00c9ee72-337a-42f1-afed-aaf2a429c9ed)

# Subtask (D)
# > Representation of the INPUT from the input .csv file in a format suitable for dumping the into the .sdc file used for synthesis 

# Input .csv file with input Constraints
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/86b82522-2a9c-4709-beea-c24aa48a39da)

# scripts :
Defining Initial variables
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/e5ec38c9-1a28-43c8-892b-45302e15f194)

Algorithm to seperate the iput ports bits and buss.
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/9c0c6109-9e77-48e3-9fb5-f29b48e31002)

Alogithm:
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/67e4f90d-f5d1-4673-abf4-532e2bc729c0)
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/07fea7e5-35f4-46ea-8aa5-db264867aa3d)

formatting in the suitable format for .sdc file
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/4e7a9be7-a5bf-46da-b3fa-e83ddc18a588)

# Result :
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/986b26a7-6f58-453c-975a-c936bfc28aa2)


# Subtask (E)
# > Representation of the OUTPUT from the input .csv file in a format suitale for dumping the into the .sdc file used for synthesis 

# Input .csv file with output Constraints
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/b726b5f0-a5ab-4064-b30e-731bbea5392a)

# scripts :

Defining initial variables.
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/b12531df-e038-474e-a0a6-ffb1898aa82f)

Algorithm Script:
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/ef14497d-896b-4f31-a065-142aeba9ded2)

formatting in the suitable format for .sdc file
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/277f4a69-5809-4e5b-b4a6-260caa2ebb2f)

# Result :
![image](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/c0f36cc5-b50a-45bb-a99c-dac2e4ddc6ce)

# subtask (F)
(a) Using the yosys tool for synthesis the gate level netlist 
(b) using Hierarchy error checklist to determine the error flags and further help in debugging the error in the design

script for automating the hierarchy check and error detection in the gate level netlist 
![Screenshot (95)](https://github.com/Swapnil-Dubey25/TCL_programming/assets/109385480/97e4a643-ea6e-49fb-8df4-e0392d22a8ee)

# TASK 3:
FURTHER USING THE OPENTIMER TOOL FOR GENERATING THE DATE SHEET.
