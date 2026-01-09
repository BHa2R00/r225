(defmacro with-fp-w ((s file) &body b)
  `(with-open-file
     (,s ,file
         :direction :output
         :if-does-not-exist :create
         :if-exists :supersede)
     ,@b))
(defmacro with-fp-w+ ((s file) &body b)
  `(with-open-file
     (,s ,file
         :direction :output
         :if-does-not-exist :create
         :if-exists :append)
     ,@b))
(defmacro with-fp-wb ((s file) &body b)
  `(with-open-file
     (,s ,file
         :direction :output
         :if-does-not-exist :create
         :if-exists :supersede
         :element-type '(unsigned-byte 8))
     ,@b))
(defmacro with-fp-wb+ ((s file) &body b)
  `(with-open-file
     (,s ,file
         :direction :output
         :if-does-not-exist :create
         :if-exists :append
         :element-type '(unsigned-byte 8))
     ,@b))
(defmacro with-fp-r ((s file) &body b)
  `(with-open-file
     (,s ,file
         :direction :input)
     ,@b))
(defmacro with-fp-rb ((s file) &body b)
  `(with-open-file
     (,s ,file
         :direction :input
         :element-type '(unsigned-byte 8))
     ,@b))
;(defmacro argv () `*command-line-argument-list*)
(defmacro argv () `sb-ext:*posix-argv*)
(defmacro argv-offset (name k) `(if (member ,name (argv) :test 'equalp) (nth (+ ,k (position ,name (argv) :test 'equalp)) (argv)) nil))
(defmacro with-sp-w ((s) &rest b) `(with-output-to-string (,s) ,@b))
(defmacro with-sp-r ((s str) &rest b) `(with-input-from-string (,s ,str) ,@b))
(defun string+ (&rest l) (with-sp-w (s) (map 'list (lambda (i) (format s "~A" i)) l)))
(defun sym+ (&rest l) (read-from-string(apply 'string+ l)))
(defmacro pscan (e s) `(cl-ppcre:scan-to-strings ,e ,s))
(defun pscan-p (e s) 
  (if (pscan 
		(if (stringp e) (string-upcase e) (string-upcase (string+ e))) 
		(if (stringp s) (string-upcase s) (string-upcase (string+ s))) 
		) 
	t nil))
(defmacro pmatch (e s) `(cl-ppcre:all-matches-as-strings ,e ,s))
(defmacro preplace (e s w) `(cl-ppcre:regex-replace-all ,e ,s ,w))
(defmacro psplit (e s) `(cl-ppcre:split ,e ,s))
(defmacro pquote (b) `(cl-ppcre:quote-meta-chars ,b))
(defparameter *path* (list "./" "/bin/" "/sbin/" "/usr/bin/" "/usr/local/bin/"))
(defun exec (s &rest l) 
  (do*((k 0 (+ k 1))
       (path (concatenate 'string (nth k *path*) (car l))
             (concatenate 'string (nth k *path*) (car l))))
    ((probe-file path)
     (sb-ext:run-program path (cdr l) :output s)
     ;(run-program path (cdr l) :output s)
     )))
(defun formverilogfilelist (dir outfile &key type part top lib clocks periods dft)
  (let ((b1 (with-output-to-string (s) (exec s "find" dir "-name" "*.v")))
        (b2 (with-output-to-string (s) (exec s "find" dir "-name" "inc")))
        (b3 (with-output-to-string (s) (exec s "find" dir "-name" "*tb.sv")))
        (b4 (with-output-to-string (s) (exec s "find" dir "-name" "*vip.sv"))))
    (with-open-file
      (s outfile 
         :direction :output 
         :if-exists :supersede
         :if-does-not-exist :create
         )
      (if (equalp type "vivado")
        (format s "set include_dirs [list]~%"))
      (if (equalp type "quartus")
        (let ()
          (format s "set top ~A~%" top)
          (format s "load_package flow~%")
          (format s "project_new \"${top}\" -overwrite~%")
          (format s "set_global_assignment -name TOP_LEVEL_ENTITY $top~%")
          (format s "set_global_assignment -name FAMILY \"Cyclone IV E\"~%")
          (format s "set_global_assignment -name DEVICE ~A~%" part)
          (format s "set_global_assignment -name PROJECT_OUTPUT_DIRECTORY ./quartus_output_files~%")
          (format s "set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0~%")
          (format s "set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85~%")
          (format s "set_global_assignment -name AUTO_RAM_RECOGNITION ON~%")
          (format s "set_global_assignment -name VERILOG_MACRO \"ALTERA=\"~%")
          ))
      (with-input-from-string (s2 b2)
        (do ((line (read-line s2 nil 'end)
                   (read-line s2 nil 'end)))
          ((equalp line 'end))
          (if (and
                (stringp line)
                (> (length(string-trim (list #\Tab #\Space #\Newline #\Return) line)) 0))
            (cond
              ((equalp type "dc_shell") (format s "lappend search_path ~A~%" line))
              ((equalp type "vivado") (format s "set include_dirs [concat ~A $include_dirs]~%" line))
              ((equalp type "quartus") (format s "set_global_assignment -name SEARCH_PATH ~A~%" line))
              ((equalp type "yosys") (format s "verilog_defaults -add -I~A ~%" line))
              (t (format s "+incdir+~A~%" line)))
            )))
      (with-input-from-string (s1 b1)
        (do ((line (read-line s1 nil 'end)
                   (read-line s1 nil 'end)))
          ((equalp line 'end))
          (if (and
                (stringp line)
                (> (length(string-trim (list #\Tab #\Space #\Newline #\Return) line)) 0))
            (cond
              ((equalp type "dc_shell") 
               (if lib
                 (format s "analyze -format verilog -define {~A } ~A~%" lib line)
                 (format s "analyze -format verilog ~A~%" line)))
              ((equalp type "vivado") (format s "add_files ~A~%" line))
              ((equalp type "quartus") (format s "set_global_assignment -name VERILOG_FILE ~A~%" line))
              ((equalp type "yosys") (format s "read_verilog ~A~%" line))
              (t (format s "~A~%" line)))
            )))
      (cond
        ((equalp type "dc_shell")
         (cond
           ((and top) 
            (let ()
              (format s "elaborate ~A -update~%" top)
              (map 'list
                   (lambda (clock period)
                     (let ()
                       (format s "create_clock -period ~A [get_ports ~A]~%" period clock)
                       ))
                   (psplit "\\s+" (string-trim '(#\Space) clocks))
                   (psplit "\\s+" (string-trim '(#\Space) periods))
                   )
              (format s 
"
set generated_clock_celllist [get_object_name [get_cells -hierarchical *_generated_clock ]]
foreach {cell} ${generated_clock_celllist} {
  puts ${cell}
  create_generated_clock \\
    -source [get_ports ${cell}/clk] \\
    -divide_by 1 \\
    [get_ports ${cell}/lck]
}
"
                      )
              (if (stringp dft)
                (let ((dftdef (psplit "\\s+" (string-trim '(#\Space) dft))))
                (format s 
"
set_dft_signal -type scanclock -port ~A
set_dft_signal -type scanenable -port ~A
set_dft_signal -type scandatain -port ~A
set_dft_signal -type scandataout -port ~A
"
                        (nth 0 dftdef)
                        (nth 1 dftdef)
                        (nth 2 dftdef)
                        (nth 3 dftdef)
                        )))
              ))
           ))
        ((equalp type "vivado")
         (cond
           ((and top part) 
            (let ()
              (format s "synth_design -verilog_define XILINX= -part ~A -top ~A -include_dirs $include_dirs -flatten_hierarchy none ~%" part top)
              #|(map 'list
                   (lambda (clock period)
                     (let ()
                       (format s "create_clock -period ~A [get_ports ~A]~%" period clock)
                       ))
                   (psplit "\\s+" (string-trim '(#\Space) clocks))
                   (psplit "\\s+" (string-trim '(#\Space) periods))
                   )|#
              (format s "read_xdc ~A/fpga/const/~A_pin_~A.xdc~%" *prjroot* top (preplace "\\s+" part ""))
              #|(format s 
"
set generated_clock_celllist [get_object_name [get_cells -hierarchical *_generated_clock ]]
foreach {cell} ${generated_clock_celllist} {
  puts ${cell}
  create_generated_clock \\
    -source [get_ports ${cell}/clk] \\
    -divide_by 1 \\
    [get_ports ${cell}/lck]
}
"
                      )|#
              (format s 
"
# opt_design
# place_design
route_design
"
                      )
              ))
           ))
        ((equalp type "quartus") 
         (let ()
           (format s "source ~A/fpga/const/~A_pin_~A.tcl~%" *prjroot* top (preplace "\\s+" part ""))
           (format s "set_global_assignment -name SDC_FILE ~A/fpga/const/~A_~A.sdc~%" *prjroot* top (preplace "\\s+" part ""))
           (format s "execute_flow -compile~%")
           (format s "export_assignments~%")
           (format s "project_close~%")
           ))
        ((equalp type "yosys")
         (let ()
           (format s "hierarchy -check -top ~A~%" top)
           (format s "check -assert~%")
           (format s "proc; opt; memory -nomap; opt; techmap; opt~%")
           ;(format s "synth_xilinx -top ~A -edif ~A.edf -json ~A.json -ise ~%" top top top)
           ;(format s "synth_intel -family cycloneive -top ~A -nodsp ~%" top)
           ;(format s "write_json ~A.json~%" top)
           ;(format s "write_edif ~A.edif~%" top)
           (format s "write_verilog ~A_mapped.v~%" top)
           ;(format s "exit~%")
           ))
        (t (format s "~A~%~A~%" b4 b3)))
      )
    ))
;(formverilogfilelist "../" "1.list")
(defun bin2memh (bin memh awidth offset &key type )
  (let*((depth (ash 1 (+ awidth offset)))
        (rom (make-list depth :initial-element 0)))
    (with-open-file 
      (s bin
         :direction :input
         :element-type '(unsigned-byte 8)
         )
      (do ((k 0 (+ k 1))
           (b (read-byte s nil 'end)
              (read-byte s nil 'end)))
        ((or
           (>= k depth)
           (equalp b 'end)))
        (setf (nth k rom) b)))
    (with-open-file 
      (s memh
         :direction :output 
         :if-exists :supersede
         :if-does-not-exist :create
         )
      (cond
        ((equalp type "mif")
         (let ()
           (format s "WIDTH = 32;~%")
           (format s "DEPTH = ~A;~%" (/ (ash 1 awidth) 4))
           (format s "ADDRESS_RADIX = UNS;~%")
           (format s "DATA_RADIX = UNS;~%")
           (format s "CONTENT BEGIN~%")
           ))
        ((and
           (equalp type "verilog")
           )
         (let ()
           (format s "~%wire [~A:0] A;~%wire [31:0] Q;~%" (- awidth offset 1))
           (format s "assign Q = ~%")
           ))
        )
      (do ((k 0 (+ k (ash 1 offset)))
           (a 0 (+ 1 a)))
        ((>= k (ash 1 awidth)))
        (cond
          ((equalp type "mif")
           (let ()
             (format s "~6d : " a)
             (let ((d 0))
               (setf d (logior 
                         (ash (nth (+ 3 k) rom) 24)
                         (ash (nth (+ 2 k) rom) 16)
                         (ash (nth (+ 1 k) rom)  8)
                         (ash (nth (+ 0 k) rom)  0)
                         ))
               (setf d (logand d (1-(ash 1 (* 8 (ash 1 offset))))))
               (format s "~12d;~%" d)
               )
             ))
          ((and 
             (equalp type "verilog") 
             )
           (if (or
                 (not(equalp 0 (nth (+ 3 k) rom)))
                 (not(equalp 0 (nth (+ 2 k) rom)))
                 (not(equalp 0 (nth (+ 1 k) rom)))
                 (not(equalp 0 (nth (+ 0 k) rom)))
                 )
             (let ()
               (format s "(A=='H~8,'0X) ? 'H" a)
               (let ()
                 (format s "~2,'0x" (nth (+ 3 k) rom))
                 (format s "~2,'0x" (nth (+ 2 k) rom))
                 (format s "~2,'0x" (nth (+ 1 k) rom))
                 (format s "~2,'0x" (nth (+ 0 k) rom))
                 (format s " : ")
                 (format s "~%")))
             ))
          (t (let ()
               ;(format s "~2,'0x" (nth (+ 3 k) rom))
               ;(format s "~2,'0x" (nth (+ 2 k) rom))
               ;(format s "~2,'0x" (nth (+ 1 k) rom))
               ;(format s "~2,'0x" (nth (+ 0 k) rom))
               (do ((i (1-(ash 1 offset)) (- i 1)))
                 ((< i 0))
                 (format s "~2,'0x" (nth (+ i k) rom))
                 )
               (format s "~%")))))
      (cond
        ((equalp type "mif")
         (let ()
           (format s "END;")
           ))
        ((and
           (equalp type "verilog")
           )
         (let ()
           (format s "0;~%")
           ))
        )
      )
    ))
;(bin2memh "boot.bin" "boot.memh" 13 2)
