#!/usr/bin/env python
import time, os, ctypes, sys, random, subprocess, shutil, getopt, serial, argparse, serial.threaded, datetime


class MySerialReader(serial.threaded.Protocol):
    def __init__(self):
        print("Created instance of Serial Reader")
        self.received = ""
        
    def __call__(self):
        print("Serial Reader called")
        return self

    def data_received(self,data):
        print("    data: ",data, "length: ", len(data))
        #print("\n")
        for i in range(len(data)):
            datum = chr(data[i])
            #print("datum: ",datum)
            if datum in ['n','1','2','3']:
                self.received = datum
                print("    set received")
                sys.stdout.flush()



class ssd_test_class:
    def __init__(self, size, rloc, args, trigger_on, trigger_off):
        self.size           = 0
        self.sname          = ""
        self.floc           = args.floc
        self.rloc           = rloc
        self.fname          = ""
        self.sleep          = int(args.wait)
        self.start          = args.start_buf
        self.stop           = args.record_time
        self.trigger_on     = trigger_on
        self.trigger_off    = trigger_off
        self.files          = []
        

    def read_test(self): 
        self.clear_cache()
        # create a file and save it the SSD
        if not os.path.isfile(self.fname):
            self.create_file()
        time.sleep(20)

        # START READ TRIAL
        print("read trial")
        self.trigger_on.write(bytes(42))
        time.sleep(int(self.start))
        #print("fname: " + self.fname)
        #print("rloc\\sname: " + self.rloc + "\\" + self.sname)
        shutil.move(self.fname,self.rloc+'\\'+self.sname)
        time.sleep(int(self.stop))
        self.trigger_off.write(bytes(42))
        # END OF READ TRIAL

        shutil.move(self.rloc+'\\'+self.sname,self.fname)
        
        self.wait()
        
        #self.clear_cache()

    def write_test(self, myReader, mode, ser, fileName):
        oldmode = mode
        mode = mode.decode()
        self.clear_cache()
        #time.sleep(2) #we added
        # create a file and save it to the C:\ Drive
        #if not os.path.isfile(self.fname):
        #    print("creating file")
        #    self.create_file()
        #print("beyond if")
        #sys.stdout.flush()
        #shutil.move(fileName, self.rloc+'\\'+self.sname) #moves file from SSD to C:\ drive
    
        #time.sleep(5) #so can change modes
        count = 0
        while myReader.received != mode:
            print("     waiting, mode is ",mode," myReader.received is ",myReader.received)
            sys.stdout.flush()
            time.sleep(1)
            count +=1
            if count>=10:
                print("     resending mode and writing small file")
                sys.stdout.flush()
                ser.write(oldmode)
                self.create_small_file(10240, self.rloc + "small_file.txt")
                sys.stdout.flush()
                count = 0
        #time.sleep(5) #waiting five seconds to ensure that SSD has time to recover from small file
        # START WRITE TRIAL
        print("write trial, ",datetime.datetime.now())
        sys.stdout.flush()
        #self.trigger_on.write(bytes(42))
        print()
        print("******************************************")
        print("Trigger recording in: 5", end=" ")
        time.sleep(1)
        print("4", end=" ")
        time.sleep(1)
        print("3", end=" ")
        time.sleep(1)
        print("2", end=" ")
        time.sleep(1)
        print("1")
        time.sleep(1)
        #time.sleep(int(self.start)) removed in case was messing with things
        #shutil.move(self.rloc+'\\'+self.sname,self.fname)
        shutil.copyfile(fileName, self.fname)
        time.sleep(int(self.stop))
        #self.trigger_off.write(bytes(42))
        print("Stop recording")
        # END OF WRITE TRIAL
        print("end of write trial, ", datetime.datetime.now())
        sys.stdout.flush()
        self.wait()
        
        #self.clear_cache()



    def just_write(self):
        self.clear_cache()
        """if os.path.isfile(self.fname):
            print(self.fname + " exists")
            os.remove(self.fname)"""
        #do a write, just don't send triggers
        if not os.path.isfile(self.fname):
            self.create_file()
        shutil.move(self.fname, self.rloc+"\\"+self.sname)
        
        time.sleep(int(self.start))
        shutil.move(self.rloc+'\\'+self.sname,self.fname)
        time.sleep(int(self.stop))

        self.wait()
        #self.clear_cache()



    def clear_cache(self):
        #print("start cache clear")
        os.system(os.getcwd()+'\collection\EmptyStandbyList.exe standbylist')
        print("end clear cache")
        sys.stdout.flush()

    def wait(self):
        for second in range(self.sleep):
            sys.stdout.write('\r'+str(self.sleep - second)+' seconds until next recording\t')
            time.sleep(1)
        sys.stdout.write('\rbeginning next recording\t\t\t\t\t\n')
        sys.stdout.flush()

    def create_file_helper(self, size, name):
        print("create file start")
        file = open(name,'wb')

        try:
            MB = os.urandom(1024 * 1024)
            for i in range(int(size)):
                file.write(MB)
            file.close()
        except:
            file.close()
            os.remove(name)
        #self.sleep(int(20))
        print("end create file")
        sys.stdout.flush()
        #self.sleep(20)

    def create_small_file(self,size,name): #takes size in bytres
        print("create small file start, ", name)
        file = open(name,'wb')

        try:
            B = os.urandom(1)
            for i in range(int(size)):
                file.write(B)
            file.close()
        except:
            file.close()
            os.remove(name)
        #self.sleep(int(20))
        print("end create file")
        sys.stdout.flush()

    def create_1s_file_helper(self, size, name):
        print("creating file of 1's")
        with open(name, 'wb') as binfile:
            binfile.write(b'\xff' * size * 1024 * 1024)
        print("create 1's file")
        sys.stdout.flush()
        
    def create_0s_file_helper(self, size, name):
        print("creating file of 0s")
        with open(name, 'wb') as binfile:
            binfile.write(b'\x00' * size * 1024 * 1024)
        print("create 0 file")
        sys.stdout.flush()

    def create_0s_file(self):
        self.create_0s_file_helper(self.size, self.fname)
        
    def create_file(self):
        self.create_file_helper(self.size, self.fname)

def ParseArgs():
    parser = argparse.ArgumentParser(description='automated test script', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("-n", "--num_trials",
                        type=int,
                        default=100,#was 20
                        help="number of read and write trials to run \n(default: %(default)s)")

    parser.add_argument("-l", "--ssd_path",
                        default= "F:\\",
                        help="path to target directory on test SSD \n(default: %(default)s)")

    parser.add_argument("-w", "--wait",
                        default=70,#was 70
                        help="idle time between trials in seconds \n(default: %(default)s)")
    
    parser.add_argument("-p", "--start_buf",
                        default=2, #was 2
                        help="seconds to begin recording before operation begins \n(default: %(default)s)")

    parser.add_argument("-t", "--record_time",
                        default=55, #was 45, increased to 60 to make sure to capture whole recording
                        help="seconds to record after event is triggered \n(default: %(default)s)")
    
    parser.add_argument("-s", "--sizes",
                        type=list,
                        default=[5], #was [4,3,2,1,4,3,2,1]
                        help="file size to test (in MB) \n(default: %(default)s)")
    #original default = [6, 24, 256, 1024]
    parser.add_argument("-f", "--floc",
                        default="F:\\",
                        help="directory of the test SSD\n(default: %(default)s)")

    parser.add_argument("-o", "--trig_on",
                        default=None, #serial.Serial('COM8',9600),
                        help="serial port that trigger recording start \n(default: serial.Serial('COM8',9600))")

    parser.add_argument("-r", "--trig_off",
                        default=None, #serial.Serial('COM8',9600),
                        help="serial port that trigger recording end\n(default: serial.Serial('COM8',9600))")
    return parser.parse_args()

def main():
    
    
    args        = ParseArgs()
    trigger_on  = args.trig_on
    trigger_off = args.trig_off
    rloc        = args.ssd_path
    sizes       = args.sizes

    #set up serial reader
    ser = serial.Serial('COM5',115200)

    myReader = MySerialReader()

    serial_worker = serial.threaded.ReaderThread(ser,myReader)
    serial_worker.start()

    #begins  encrypting / printing process
    ser.write(b's')

    modeChars = ["w", b'2', b'3']

    for size_index in range(len(sizes)):
        test = ssd_test_class(0, rloc, args, trigger_on, trigger_off)
        test.size = int(sizes[size_index])
        sys.stdout.write('\n\rStarting file size: '+str(sizes[size_index])+'MB\t\t\t\t\n')
        test.sname = str(test.size)+"MB.txt"
        #test.fname = test.floc + '\\' + test.sname
        #test.create_1s_file_helper(1,"1's.bin")

        #quit()
        #create appropriate files
        test.create_file_helper(test.size, os.getcwd() + "\\random.txt")
        test.create_0s_file_helper(test.size, os.getcwd() + "\\0's.txt")
        test.create_1s_file_helper(test.size, os.getcwd() + "\\1's.txt")
        test.files = ["1's.txt"]#["random.txt","0's.txt","1's.txt"]
        
       
        print(test.sname)
        print(test.fname)
        #print(test.dstname)
        for file in test.files:
            print(file)
            test.fname = test.floc + "\\" + file
            for trial in range(args.num_trials):
                for mode in modeChars:
                    if mode == "w":
                        #do nothing for short time
                        print("small pass, ",datetime.datetime.now())
                        sys.stdout.flush()
                        #test.trigger_on.write(bytes(42))
                        time.sleep(int(test.start))
                        #shutil.move(self.rloc+'\\'+self.sname,self.fname)
                        #time.sleep(int(test.stop))
                        #test.trigger_off.write(bytes(42))
                        # END OF WRITE TRIAL
                        print("end of small pass, ", datetime.datetime.now())
                        sys.stdout.flush()
                        test.wait()
                    else:
                        ser.write(mode)
                        print("sent char: ",mode);
                        sys.stdout.flush()
                        #time.sleep(5);
                        test.write_test(myReader, mode, ser,file) #needed to decode bytes to char to match myReader.received
                    #test.read_test()
            
            

    quit()
#Note for Jasmine: increase recording time? some action may happen after finished writing?
main()
#Note on error characters: z = SDRAM, tried to go beyond boundary; b = BSP interrupt

