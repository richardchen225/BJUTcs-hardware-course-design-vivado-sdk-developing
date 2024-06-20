################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/Robotarm_ps.c \
../src/oled.c 

CPP_SRCS += \
../src/chess.cpp \
../src/ov5640.cpp \
../src/robot.cpp \
../src/tts.cpp 

OBJS += \
./src/Robotarm_ps.o \
./src/chess.o \
./src/oled.o \
./src/ov5640.o \
./src/robot.o \
./src/tts.o 

C_DEPS += \
./src/Robotarm_ps.d \
./src/oled.d 

CPP_DEPS += \
./src/chess.d \
./src/ov5640.d \
./src/robot.d \
./src/tts.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM g++ compiler'
	arm-xilinx-eabi-g++ -Wall -O0 -g3 -I"C:\Xilinx\SDK\2015.2\gnu\arm\nt\arm-xilinx-eabi\include\c++\4.9.1" -I"C:\Xilinx\SDK\2015.2\gnu\arm\nt\arm-xilinx-eabi\include\c++\4.9.1\arm-xilinx-eabi" -I"C:\Xilinx\SDK\2015.2\gnu\arm\nt\arm-xilinx-eabi\include\c++\4.9.1\backward" -c -fmessage-length=0 -MT"$@" -I../../robot_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/%.o: ../src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: ARM g++ compiler'
	arm-xilinx-eabi-g++ -Wall -O0 -g3 -I"C:\Xilinx\SDK\2015.2\gnu\arm\nt\arm-xilinx-eabi\include\c++\4.9.1" -I"C:\Xilinx\SDK\2015.2\gnu\arm\nt\arm-xilinx-eabi\include\c++\4.9.1\arm-xilinx-eabi" -I"C:\Xilinx\SDK\2015.2\gnu\arm\nt\arm-xilinx-eabi\include\c++\4.9.1\backward" -c -fmessage-length=0 -MT"$@" -I../../robot_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


