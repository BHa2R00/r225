(defparameter *addr* 0)
(defparameter *place-list* (list))
(defparameter *bus-list* (list))
(defparameter *addr-list* (list))
(defparameter *in-list* (list))
(defparameter *out-list* (list))
(defparameter *imux-dst-list* (list))
(defparameter *omux-src-list* (list))
(defparameter *master-list* (list))
(defparameter *scan-mode* "scan_mode")
(defparameter *clk* "interconnect_clk")
(defparameter *rstb* "interconnect_rstb")
(defparameter *clk-list* (list))
(defparameter *rstb-list* (list))
(defparameter *pannel-list* (list))
(defparameter *pannel-word-list* (list))
(defparameter *pannel-c-typedef* "")
(defparameter *memory-map* (list))
(defparameter *rom-addr0* 0)
(defparameter *rom-addr1* 0)
(defparameter *ram-addr0* 0)
(defparameter *ram-addr1* 0)
(defparameter *dev-addr0* 0)
(defparameter *dev-addr1* 0)


(defun clear ()
	(setf *addr* 0)
	(setf *place-list* (list))
	(setf *bus-list* (list))
	(setf *addr-list* (list))
	(setf *in-list* (list))
	(setf *out-list* (list))
	(setf *imux-dst-list* (list))
	(setf *omux-src-list* (list))
	(setf *master-list* (list))
	(setf *clk* "interconnect_clk")
	(setf *rstb* "interconnect_rstb")
	(setf *clk-list* (list))
	(setf *rstb-list* (list))
	(setf *pannel-list* (list))
	(setf *pannel-word-list* (list))
  (setf *pannel-c-typedef* "")
  (setf *memory-map* (list))
  )


(defun connect (s)
  (format t "connect start time: ~D~%" (get-universal-time))
  (format s "~%")
  (format s "wire        pannel_clk   = ~A ;~%" *clk*)
  (format s "wire        pannel_rstb  = ~A ;~%" *rstb*)
  (format s "wire        pannel_valid ;~%")
  (format s "wire [ 1:0] pannel_size  ;~%")
  (format s "wire [31:0] pannel_addr  ;~%")
  (format s "wire        pannel_write ;~%")
  (format s "wire [31:0] pannel_wdata ;~%")
  (format s "reg  [31:0] pannel_rdata ;~%")
  (format s "reg         pannel_ready ;~%")
  (setf *place-list*
  (map 'list
       (lambda (inst)
         (if (and
               (listp inst)
               (stringp (car inst))
               )
         (map 'list
              (lambda (elm)
                (cond
                  ((and (listp elm) (equalp (car elm) 'slave))
                   (let ((b-list (nth 1 elm))
                         (l (nth 2 elm))
                         (p (list))
                         (bytes (nth 3 elm))
                         (base (nth 4 elm))
                         (b-list-valid (list))
                         (b-list-grant (list))
                         (b-list-grant-sync (list))
                         (b-list-valid-r (list))
                         (b-list-size (list))
                         (b-list-addr (list))
                         (b-list-write (list))
                         (b-list-wdata (list))
                         )
                     (map 'list
                     (lambda (b)
                     (if (not (assoc b *bus-list* :test 'equalp)) 
                       (let ()
                         (push (list b nil) *bus-list*)
                         (format s "~%// ~A ~%" b)
                         (format s "wire        ~A ;~%" (concatenate 'string b"_clk   "))
                         (format s "wire        ~A ;~%" (concatenate 'string b"_rstb  "))
                         (format s "wire        ~A ;~%" (concatenate 'string b"_valid "))
                         (format s "wire [ 1:0] ~A ;~%" (concatenate 'string b"_size  "))
                         (format s "wire [31:0] ~A ;~%" (concatenate 'string b"_addr  "))
                         (format s "wire [31:0] ~A ;~%" (concatenate 'string b"_rdata "))
                         (format s "wire        ~A ;~%" (concatenate 'string b"_write "))
                         (format s "wire [31:0] ~A ;~%" (concatenate 'string b"_wdata "))
                         (format s "wire        ~A ;~%" (concatenate 'string b"_ready "))
                         (format s "wire [31:0] ~A ;~%" (concatenate 'string b"_addr0 "))
                         (format s "wire [31:0] ~A ;~%" (concatenate 'string b"_addr1 "))
                         (push (concatenate 'string b"_clk") *clk-list*)
                         (push (concatenate 'string b"_rstb") *rstb-list*)
                         ))
                     (format s "~%// ~A slave ~A ~%" b (car inst))
                     (setf *bus-list*
                     (map 'list
                          (lambda (bus)
                            (if (equalp b (car bus))
                              (let ((bus1 bus)
                                    (item (list)))
                                (if base (push base item))
                                (if bytes (push bytes item))
                                (push (concatenate 'string (car inst)"_"l) item)
                                (push 'slave item)
                                (setf bus1 (append bus1 (list item)))
                                bus1)
                              bus))
                          *bus-list*))
                     (if (equalp l nil) (setf l ""))
                     (format s "wire        ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"clk   "))
                     (format s "wire        ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"rstb  "))
                     (format s "wire        ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"valid "))
                     (format s "wire [ 1:0] ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"size  "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"addr  "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"rdata "))
                     (format s "wire        ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"write "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"wdata "))
                     (format s "wire        ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"ready "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"addr0 "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"addr1 "))
                     (format s "assign ~A = ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"write ") (concatenate 'string b"_write "))
                     (format s "assign ~A = ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"wdata ") (concatenate 'string b"_wdata "))
                     (if (not(equalp (car inst) "pannel")) 
                       (let ()
                         (push (concatenate 'string b"_"(car inst)"_"l"clk") *clk-list*)
                         (push (concatenate 'string b"_"(car inst)"_"l"rstb") *rstb-list*)
                         ))
                     (push (concatenate 'string b"_"(car inst)"_"l"valid") b-list-valid)
                     (push (concatenate 'string b"_"(car inst)"_"l"grant") b-list-grant)
                     (push (concatenate 'string b"_"(car inst)"_"l"grant ? "b"_"(car inst)"_"l"valid :") b-list-valid-r)
                     (push (concatenate 'string b"_"(car inst)"_"l"grant ? "b"_"(car inst)"_"l"size  :") b-list-size )
                     (push (concatenate 'string b"_"(car inst)"_"l"grant ? "b"_"(car inst)"_"l"addr  :") b-list-addr )
                     (push (concatenate 'string b"_"(car inst)"_"l"grant ? "b"_"(car inst)"_"l"write :") b-list-write)
                     (push (concatenate 'string b"_"(car inst)"_"l"grant ? "b"_"(car inst)"_"l"wdata :") b-list-wdata)
                     (push 
                       (with-output-to-string (s1)
                         (format s1 
"
always@(negedge ~A or posedge ~A) begin
  if(!~A) begin
    ~A_d <= 1'b0;
  end
  else begin
    ~A_d <= ~A;
  end
end

assign ~A = ~A_d && ~A ;
assign ~A = ~A ;
"
                                 (concatenate 'string b"_"(car inst)"_"l"rstb ") (concatenate 'string b"_"(car inst)"_"l"clk  ")
                                 (concatenate 'string b"_"(car inst)"_"l"rstb ")
                                 (concatenate 'string b"_"(car inst)"_"l"grant")
                                 (concatenate 'string b"_"(car inst)"_"l"grant") (concatenate 'string b"_"(car inst)"_"l"grant")
                                 (concatenate 'string b"_"(car inst)"_"l"ready  ") (concatenate 'string b"_"(car inst)"_"l"grant") (concatenate 'string (car inst)"_"l"ready  ")
                                 (concatenate 'string b"_"(car inst)"_"l"rdata") (concatenate 'string (car inst)"_"l"rdata")
                                 ))
                       b-list-grant-sync)
                     ) b-list)
                     (if (not(equalp (car inst) "pannel"))
                     (let ()
                     (format s "~%// slave arbiter of ~A ~%" (car inst))
                     (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"l"clk   "))
                     (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"l"rstb  "))
                     (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"l"valid "))
                     (format s "wire [ 1:0] ~A ;~%" (concatenate 'string (car inst)"_"l"size  "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string (car inst)"_"l"addr  "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string (car inst)"_"l"rdata "))
                     (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"l"write "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string (car inst)"_"l"wdata "))
                     (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"l"ready "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string (car inst)"_"l"addr0 "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string (car inst)"_"l"addr1 "))
                     (push (concatenate 'string (car inst)"_"l"clk") *clk-list*)
                     (push (concatenate 'string (car inst)"_"l"rstb") *rstb-list*)
                     ))
                     (if (<= (length b-list) 1)
                       (let ((b (car b-list)))
                         (format s "assign ~A = ~A ;~%" (concatenate 'string (car inst)"_"l"valid ") (concatenate 'string b"_"(car inst)"_"l"valid "))
                         (format s "assign ~A = ~A ;~%" (concatenate 'string (car inst)"_"l"size  ") (concatenate 'string b"_"(car inst)"_"l"size  "))
                         (format s "assign ~A = ~A ;~%" (concatenate 'string (car inst)"_"l"addr  ") (concatenate 'string b"_"(car inst)"_"l"addr  "))
                         (format s "assign ~A = ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"rdata ") (concatenate 'string (car inst)"_"l"rdata "))
                         (format s "assign ~A = ~A ;~%" (concatenate 'string (car inst)"_"l"write ") (concatenate 'string b"_"(car inst)"_"l"write "))
                         (format s "assign ~A = ~A ;~%" (concatenate 'string (car inst)"_"l"wdata ") (concatenate 'string b"_"(car inst)"_"l"wdata "))
                         (format s "assign ~A = ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"ready ") (concatenate 'string (car inst)"_"l"ready "))
                         )
                       (let ()
                         (format s 
"
wire ~{~A~^, ~};
reg ~{~A_d~^, ~};
assign {~{~A~^, ~}} = 
  {~{~A~^, ~}} & 
  ~C({~{~A~^, ~}}-{{~D{1'b0}},1'b1});
~{~A~}
assign ~A = ~{~%  ~A ~}~%1'b0;
assign ~A = ~{~%  ~A ~}~%2'h0;
assign ~A = ~{~%  ~A ~}~%32'h0;
assign ~A = ~{~%  ~A ~}~%1'b0;
assign ~A = ~{~%  ~A ~}~%32'h0;

"
                                 b-list-grant
                                 b-list-grant
                                 (reverse b-list-grant) 
                                 (reverse b-list-valid) 
                                 #\~ (reverse b-list-valid) (1-(length b-list)) 
                                 b-list-grant-sync
                                 (concatenate 'string (car inst)"_"l"valid ") b-list-valid-r
                                 (concatenate 'string (car inst)"_"l"size  ") b-list-size
                                 (concatenate 'string (car inst)"_"l"addr  ") b-list-addr
                                 (concatenate 'string (car inst)"_"l"write ") b-list-write
                                 (concatenate 'string (car inst)"_"l"wdata ") b-list-wdata
                                 )
                         ))
                     (push (concatenate 'string ". "l"clk   ( "(car inst)"_"l"clk   )") p)
                     (push (concatenate 'string ". "l"rstb  ( "(car inst)"_"l"rstb  )") p)
                     (push (concatenate 'string ". "l"valid ( "(car inst)"_"l"valid )") p)
                     (push (concatenate 'string ". "l"size  ( "(car inst)"_"l"size  )") p)
                     (push (concatenate 'string ". "l"addr  ( "(car inst)"_"l"addr  )") p)
                     (push (concatenate 'string ". "l"rdata ( "(car inst)"_"l"rdata )") p)
                     (push (concatenate 'string ". "l"write ( "(car inst)"_"l"write )") p)
                     (push (concatenate 'string ". "l"wdata ( "(car inst)"_"l"wdata )") p)
                     (push (concatenate 'string ". "l"ready ( "(car inst)"_"l"ready )") p)
                     (push 'pins p)
                     p))
                  ((and (listp elm) (equalp (car elm) 'in))
                   (let ((p (list))
                         (n (nth 1 elm))
                         (msb (nth 2 elm)))
                     (format s "~%// input of ~A~%" (car inst))
                     (if (numberp msb)
                       (let ()
                         (format s "wire [~D:0] ~A ;~%" msb (concatenate 'string (car inst)"_"n))
                         (push (list (concatenate 'string (car inst)"_"n) msb) *in-list*)
                         )
                       (let ()
                         (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"n))
                         (push (list (concatenate 'string (car inst)"_"n)) *in-list*)
                         )
                       )
                     (push (concatenate 'string ". "n" ( "(car inst)"_"n" )") p)
                     (push 'pins p)
                     p))
                  ((and (listp elm) (equalp (car elm) 'out))
                   (let ((p (list))
                         (n (nth 1 elm))
                         (msb (nth 2 elm)))
                     (format s "~%// output of ~A~%" (car inst))
                     (if (numberp msb)
                       (let ()
                         (format s "wire [~D:0] ~A ;~%" msb (concatenate 'string (car inst)"_"n))
                         (push (list (concatenate 'string (car inst)"_"n) msb) *out-list*)
                         )
                       (let ()
                         (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"n))
                         (push (list (concatenate 'string (car inst)"_"n)) *out-list*)
                         )
                       )
                     (push (concatenate 'string ". "n" ( "(car inst)"_"n" )") p)
                     (push 'pins p)
                     p))
                  ((and (listp elm) (equalp (car elm) 'imux))
                   (let ((p (list))
                         (n (nth 1 elm)))
                     (format s "~%// imux of ~A~%" (car inst))
                     (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"n))
                     (push (list (concatenate 'string (car inst)"_"n) (if (nth 2 elm) (nth 2 elm) "1'b1")) *imux-dst-list*)
                     (push (concatenate 'string ". "n" ( "(car inst)"_"n" )") p)
                     (push 'pins p)
                     p))
                  ((and (listp elm) (equalp (car elm) 'omux))
                   (let ((p (list))
                         (n (nth 1 elm)))
                     (format s "~%// omux of ~A~%" (car inst))
                     (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"n))
                     (push (concatenate 'string (car inst)"_"n) *omux-src-list*)
                     (push (concatenate 'string ". "n" ( "(car inst)"_"n" )") p)
                     (push 'pins p)
                     p))
                  ((and (listp elm) (equalp (car elm) 'master))
                   (let*((p (list))
                         (l (nth 1 elm))
                         (b-prio-list (cddr elm))
                         (b-ready-list (list))
                         (b-rdata-list (list)))
                     (map 'list (lambda (b-prio)
                     (let ((b (nth 0 b-prio))
                           (prio (nth 1 b-prio)))
                     (if (not (assoc b *master-list* :test 'equalp)) 
                       (let ()
                         (format s "~%// ~A master~%" b)
                         (push (list b) *master-list*)))
                     (setf *master-list*
                     (map 'list
                          (lambda (bus)
                            (let ((bus1 bus))
                              (if (equalp (car bus1) b)
                                (setf bus1 (append bus1 (list(list (concatenate 'string (car inst)"_"l) prio)))))
                              bus1))
                          *master-list*))
                     (format s "wire        ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"clk  "))
                     (format s "wire        ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"rstb "))
                     (format s "wire        ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"valid"))
                     (format s "wire [ 1:0] ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"size "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"addr "))
                     (format s "wire        ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"write"))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"wdata"))
                     (format s "wire        ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"ready"))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string b"_"(car inst)"_"l"rdata"))
                     (if (not(equalp (car inst) "pannel"))
                       (let ()
                         (push (concatenate 'string b"_"(car inst)"_"l"clk") *clk-list*)
                         (push (concatenate 'string b"_"(car inst)"_"l"rstb") *rstb-list*)
                         ))
                     (push (concatenate 'string b"_"(car inst)"_"l"ready") b-ready-list)
                     (push (concatenate 'string b"_"(car inst)"_"l"ready ? "b"_"(car inst)"_"l"rdata : ") b-rdata-list)
                     )) b-prio-list)
                     (format s "~%// master ~A~%" (car inst))
                     (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"l"clk   "))
                     (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"l"rstb  "))
                     (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"l"valid "))
                     (format s "wire [ 1:0] ~A ;~%" (concatenate 'string (car inst)"_"l"size  "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string (car inst)"_"l"addr  "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string (car inst)"_"l"rdata "))
                     (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"l"write "))
                     (format s "wire [31:0] ~A ;~%" (concatenate 'string (car inst)"_"l"wdata "))
                     (format s "wire        ~A ;~%" (concatenate 'string (car inst)"_"l"ready "))
                     (if (not(equalp (car inst) "pannel")) 
                       (let ()
                         (push (concatenate 'string (car inst)"_"l"clk") *clk-list*)
                         (push (concatenate 'string (car inst)"_"l"rstb") *rstb-list*)
                         ))
                     (push (concatenate 'string ". "l"clk   ( "(car inst)"_"l"clk   )") p)
                     (push (concatenate 'string ". "l"rstb  ( "(car inst)"_"l"rstb  )") p)
                     (push (concatenate 'string ". "l"valid ( "(car inst)"_"l"valid )") p)
                     (push (concatenate 'string ". "l"size  ( "(car inst)"_"l"size  )") p)
                     (push (concatenate 'string ". "l"addr  ( "(car inst)"_"l"addr  )") p)
                     (push (concatenate 'string ". "l"rdata ( "(car inst)"_"l"rdata )") p)
                     (push (concatenate 'string ". "l"write ( "(car inst)"_"l"write )") p)
                     (push (concatenate 'string ". "l"wdata ( "(car inst)"_"l"wdata )") p)
                     (push (concatenate 'string ". "l"ready ( "(car inst)"_"l"ready )") p)
                     (format s "assign ~A = |{~{~A~^, ~}};~%" (concatenate 'string (car inst)"_"l"ready ") b-ready-list)
                     (format s "assign ~A = ~%~{  ~A~%~}32'h0;~%" (concatenate 'string (car inst)"_"l"rdata ") b-rdata-list)
                     (push 'pins p)
                     p))
                  (t elm)))
              inst)))
       *place-list*))
  (setf *bus-list* (reverse *bus-list*))
  (setf *addr* 0)
  (setf *bus-list*
  (map 'list
       (lambda (bus)
         (let ((bus1 bus)
               (b (car bus))
               (rdata-list (list))
               (ready-list (list))
               (ba0 nil)
               (ba1 nil))
           (setf (nth 1 bus1) *addr*)
           (setf ba0 *addr*)
           (format t "~20A : 0x~8,'0x~%" (car bus) *addr*)
           (setf bus1 
           (map 'list
                (lambda (elm)
                  (cond
                    ((and (listp elm) (equalp (car elm) 'slave))
                     (let ((a0 nil)
                           (a1 nil))
                       (format t "~20A " (concatenate 'string "|_ "(nth 1 elm)))
                       (format t ": 0x~8,'0x " *addr*)
                       (push (list (concatenate 'string (car bus)"_"(nth 1 elm)) *addr*) *memory-map*)
                       ;(setf a0 (- *addr* ba0))
                       (setf a0 *addr*)
                       (setf *addr* (+ *addr* (nth 2 elm)))
                       (push (concatenate 'string b"_"(nth 1 elm)"ready ? "b"_"(nth 1 elm)"rdata : ") rdata-list)
                       (push (concatenate 'string b"_"(nth 1 elm)"ready") ready-list)
                       (format t "-> 0x~8,'0x~%" (- *addr* 4))
                       (setf (car *memory-map*) (append (car *memory-map*) (list (- *addr* 4))))
                       ;(setf a1 (- *addr* ba0 4))
                       (setf a1 (- *addr* 4))
                       (push (list (concatenate 'string b"_"(nth 1 elm)) a0 a1) *addr-list*)
                       elm))
                    (t elm)))
                bus1))
           (format s "assign ~A = ~%~{  ~A~%~}32'h0;~%" (concatenate 'string b"_rdata ") rdata-list)
           (format s "assign ~A = |{~{~A~^, ~}};~%" (concatenate 'string b"_ready ") ready-list)
           (setf ba1 (- *addr* 4))
           (format t "~20A-> 0x~8,'0x~%" "" (- *addr* 4))
           (push (list (concatenate 'string b"_") ba0 ba1) *addr-list*)
           bus1))
       *bus-list*))
  (setf *addr-list* (reverse *addr-list*))
  (format s "~%")
  (map 'list
       (lambda (a)
         (format s "assign ~A = 32'h~8,'0x;~%" (concatenate 'string (nth 0 a)"addr0") (nth 1 a))
         (format s "assign ~A = 32'h~8,'0x;~%" (concatenate 'string (nth 0 a)"addr1") (nth 2 a))
         )
       *addr-list*)
  (format s "~%")
  (map 'list
       (lambda (bus)
         (map 'list
              (lambda (elm)
                (cond
                  ((and (list elm) (equalp (car elm) 'slave))
                   (let ((b (car bus))
                         (l (nth 1 elm)))
                     (format s "assign ~A = ~A;~%"
                             (concatenate 'string b"_"l"size")
                             (concatenate 'string b"_size")
                             )
                     (format s "assign ~A = ~A - ~A;~%"
                             (concatenate 'string b"_"l"addr")
                             (concatenate 'string b"_addr")
                             (concatenate 'string b"_"l"addr0")
                             )
                     (format s "assign ~A = ~A && (~A >= ~A) && (~A < (~A + 4));~%"
                             (concatenate 'string b"_"l"valid")
                             (concatenate 'string b"_valid")
                             (concatenate 'string b"_addr")
                             (concatenate 'string b"_"l"addr0")
                             (concatenate 'string b"_addr")
                             (concatenate 'string b"_"l"addr1")
                             )
                     ))
                  ))
              (cddr bus)))
       *bus-list*)
  (format t "~%")
  (format t "master: ~%")
  (setf *master-list*
  (map 'list
       (lambda (mst)
         (let ((mst1 mst))
           (setf mst1 (sort (cdr mst1) #'> :key #'cadr))
           (push (car mst) mst1)
           (setf mst1 (map 'list (lambda (m1) (if (listp m1) (car m1) m1)) mst1))
           (format t "~20A<- ~A~%" (car mst1) (cdr mst1))
           (format s "~%// master arbiter of ~A ~%" (car mst1))
           (if (> (length (cdr mst1)) 1)
             (let ((valid-list (list))
                   (grant-list (list))
                   (grant-sync-list (list))
                   (valid-r-list (list))
                   (size-list (list))
                   (addr-list (list))
                   (write-list (list))
                   (wdata-list (list)))
               (map 'list
                    (lambda (m)
                      (format s "assign ~A = ~A && (~A >= ~A) && (~A <= ~A);~%" 
                              (concatenate 'string (car mst1)"_"m"valid") 
                              (concatenate 'string m"valid") 
                              (concatenate 'string m"addr") (concatenate 'string (car mst1)"_addr0") 
                              (concatenate 'string m"addr") (concatenate 'string (car mst1)"_addr1") 
                              )
                      (format s "assign ~A = ~A ;~%" (concatenate 'string (car mst1)"_"m"size" ) (concatenate 'string m"size" ))
                      (format s "assign ~A = ~A ;~%" (concatenate 'string (car mst1)"_"m"addr" ) (concatenate 'string m"addr" ))
                      (format s "assign ~A = ~A ;~%" (concatenate 'string (car mst1)"_"m"write") (concatenate 'string m"write"))
                      (format s "assign ~A = ~A ;~%" (concatenate 'string (car mst1)"_"m"wdata") (concatenate 'string m"wdata"))
                      (push (concatenate 'string (car mst1)"_"m"valid") valid-list)
                      (push (concatenate 'string (car mst1)"_"m"grant") grant-list)
                      ;(format s "wire ~A;~%" (concatenate 'string (car mst1)"_"m"valid  "))
                      (format s "wire ~A;~%" (concatenate 'string (car mst1)"_"m"grant"))
                      (push 
                        (with-output-to-string (s1)
                          (format s1 
"
always@(negedge ~A or posedge ~A) begin
  if(!~A) begin
    ~A_d <= 1'b0;
  end
  else begin
    ~A_d <= ~A;
  end
end

assign ~A = ~A_d && ~A ;
"
                                  (concatenate 'string (car mst1)"_"m"rstb") (concatenate 'string (car mst1)"_"m"clk")
                                  (concatenate 'string (car mst1)"_"m"rstb") 
                                  (concatenate 'string (car mst1)"_"m"grant") 
                                  (concatenate 'string (car mst1)"_"m"grant") (concatenate 'string (car mst1)"_"m"grant") 
                                  (concatenate 'string (car mst1)"_"m"ready") (concatenate 'string (car mst1)"_"m"grant") (concatenate 'string (car mst1)"_ready") 
                                  )) 
                        grant-sync-list)
                      (push (concatenate 'string (car mst1)"_"m"grant ? "(car mst1)"_"m"valid : " ) valid-r-list)
                      (push (concatenate 'string (car mst1)"_"m"grant ? "(car mst1)"_"m"size  : " ) size-list)
                      (push (concatenate 'string (car mst1)"_"m"grant ? "(car mst1)"_"m"addr  : " ) addr-list)
                      (push (concatenate 'string (car mst1)"_"m"grant ? "(car mst1)"_"m"write : " ) write-list)
                      (push (concatenate 'string (car mst1)"_"m"grant ? "(car mst1)"_"m"wdata : " ) wdata-list)
                      (format s "assign ~A = ~A ;~%" (concatenate 'string (car mst1)"_"m"rdata") (concatenate 'string (car mst1)"_rdata"))
                      )
                    (reverse (cdr mst1)))
               (format s 
"
reg ~{~A_d~^, ~};
assign {~{~A~^, ~}} = 
  {~{~A~^, ~}} & 
  ~C({~{~A~^, ~}}-{{~D{1'b0}},1'b1});
~{~A~}
assign ~A = ~{~%  ~A ~}~%1'b0;
assign ~A = ~{~%  ~A ~}~%2'h0;
assign ~A = ~{~%  ~A ~}~%32'h0;
assign ~A = ~{~%  ~A ~}~%1'b0;
assign ~A = ~{~%  ~A ~}~%32'h0;

"
                                 grant-list
                                 (reverse grant-list) 
                                 (reverse valid-list) 
                                 #\~ (reverse valid-list) (1-(length (cdr mst1))) 
                                 grant-sync-list
                                 (concatenate 'string (car mst1)"_valid ") valid-r-list
                                 (concatenate 'string (car mst1)"_size  ") size-list
                                 (concatenate 'string (car mst1)"_addr  ") addr-list
                                 (concatenate 'string (car mst1)"_write ") write-list
                                 (concatenate 'string (car mst1)"_wdata ") wdata-list
                                 )
               )
             (let ()
               (format s "assign ~A = ~A ;~%" (concatenate 'string (car mst1)"_valid") (concatenate 'string (cadr mst1)"valid"))
               (format s "assign ~A = ~A ;~%" (concatenate 'string (car mst1)"_size ") (concatenate 'string (cadr mst1)"size "))
               (format s "assign ~A = ~A ;~%" (concatenate 'string (car mst1)"_addr ") (concatenate 'string (cadr mst1)"addr "))
               (format s "assign ~A = ~A ;~%" (concatenate 'string (car mst1)"_write") (concatenate 'string (cadr mst1)"write"))
               (format s "assign ~A = ~A ;~%" (concatenate 'string (car mst1)"_wdata") (concatenate 'string (cadr mst1)"wdata"))
               (format s "assign ~A = ~A ;~%" (concatenate 'string (cadr mst1)"ready") (concatenate 'string (car mst1)"_ready"))
               (format s "assign ~A = ~A ;~%" (concatenate 'string (cadr mst1)"rdata") (concatenate 'string (car mst1)"_rdata"))
               ))
           mst1))
       *master-list*))
  (format t "~%")
  (format t "imux:~%~A~%~%" *imux-dst-list*)
  (format t "omux:~%~A~%~%" *omux-src-list*)
  )


(defun place (s)
  (format t "place start time: ~D~%" (get-universal-time))
  (map 'list
       (lambda (inst)
         (if (and
               (stringp (car inst))
               (not(equalp (nth 1 inst) "pannel"))
               )
         (let ((as (car inst))
               (ref (nth 1 inst))
               (parms (list))
               (pins (list)))
           (map 'list
                (lambda (elm)
                  (if (and (listp elm) (equalp (car elm) 'ref)) (setf ref (nth 1 elm)))
                  (if (and (listp elm) (equalp (car elm) 'parms)) (setf parms (append parms (cdr elm))))
                  (if (and (listp elm) (equalp (car elm) 'pins)) (setf pins (append pins (cdr elm))))
                  )
                (cdr inst))
           (format s "~%~A~%" ref)
           (if parms (format s "#(~{~%  ~A~^,~}~%)" parms))
           (format s "~A~%" as)
           (if pins (format s "(~{~%  ~A~^,~}~%);~%" pins))
           )))
       *place-list*)
  (format s "~%")
  (format s "// clock gatting ~%")
  (format t "*clk-list* : ~S~%" *clk-list*)
  (map 'list
       (lambda (clk)
         (format s 
"reg ~A_en;
clkgate u_~A_icg (~A, ~A_en, ~A, ~A);
"
                 clk
                 clk *clk* clk clk *scan-mode*
                 )
         (push (list (concatenate 'string clk"_en") 1 "wr" "1'b1") *pannel-list*)
         )
       *clk-list*)
  (format s "// release ~%")
  (map 'list
       (lambda (rstb clk)
         (format s 
"rvld u_~A (~A, ~A, ~A, ~A);
"
                 rstb rstb *rstb* clk *scan-mode* 
                 )
         )
       *rstb-list*
       *clk-list*
       )
  (format s "~%")
  (format t "*pannel-list* : ~S~%" *pannel-list*)
  (if *pannel-list*
    (let ((bit-cnt 0)
          (reg (list))
          (c-typedef-words (list)))
      (setf *pannel-c-typedef* (with-output-to-string (s1)
      (format t "place pannel~%")
      (format s "// pannel~%")
      (format s "always@(negedge pannel_rstb or posedge pannel_clk) begin~%")
      (format s "  if(!pannel_rstb) begin~%")
      (format s "    pannel_ready   <=  1'b0 ;~%")
      (format s "    pannel_rdata <= 32'h0 ;~%")
      (setf bit-cnt 0)
      (map 'list
           (lambda (elm)
             (if (and
                   (stringp (nth 2 elm))
                   (member #\W (coerce (string-upcase (nth 2 elm)) 'list)))
               (format s "    ~20A <= ~20A ;~%" (nth 0 elm) (nth 3 elm)))
             (push elm reg)
             (if (= 31 (rem bit-cnt 32))
               (let ()
                 (setf reg (reverse reg))
                 (push reg *pannel-word-list*)
                 (setf reg (list))
                 ))
             (incf bit-cnt)
             )
           *pannel-list*)
      (if reg
        (let ((unused (list "unused" (- 32 (length reg)) "r")))
          (if (< (length reg) 32) (push unused reg))
          (setf reg (reverse reg))
          (push reg *pannel-word-list*)
          (setf reg (list))
          ))
      (setf *pannel-word-list* (reverse *pannel-word-list*))
      (format s "  end~%")
      (format s "  else begin~%")
      (format s "    pannel_ready <= pannel_valid ;~%")
      (format s "    pannel_rdata <= 32'h0 ;~%")
      (format s "    if(pannel_valid) begin~%")
      (format s "      case(pannel_addr)~%")
      (dotimes (word-cnt (length *pannel-word-list*))
        (let ((reg (nth word-cnt *pannel-word-list*))
              (addr (* 4 word-cnt)))
          (format s1 
"typedef union
{
  volatile unsigned int r;
  struct
  {
"
                  )
          (format s "        'h~8,'0X : begin~%" addr)
          (setf bit-cnt 0)
          (map 'list
               (lambda (elm)
                 (format s1 "    volatile unsigned int ~20A : ~2D;~%" (car (nth bit-cnt reg)) (nth 1 elm))
                 (if (not(equalp (car elm) "unused"))
                 (if (<= (nth 1 elm) 1)
                   (let ()
                     (format s "          pannel_rdata[~2d] <= ~20A ;~%" bit-cnt (car (nth bit-cnt reg)))
                     (incf bit-cnt))
                   (let ()
                     (format s "          pannel_rdata[~2d:~2d] <= ~20A ;~%" (1-(+ bit-cnt (nth 1 elm))) bit-cnt (car (nth bit-cnt reg)))
                     (incf bit-cnt (nth 1 elm))
                     )))
                 )
               reg)
          (format s "          if(pannel_write) begin~%")
          (setf bit-cnt 0)
          (map 'list
               (lambda (elm)
                 (if (and 
                       (not(equalp (car elm) "unused"))
                       (stringp (nth 2 elm))
                       (member #\W (coerce (string-upcase (nth 2 elm)) 'list)))
                 (if (<= (nth 1 elm) 1)
                   (let ()
                     (format s "          ~20A <= pannel_wdata[~2d] ;~%" (car (nth bit-cnt reg)) bit-cnt)
                     (incf bit-cnt))
                   (let ()
                     (format s "          ~20A <= pannel_rdata[~2d:~2d] ;~%" (car (nth bit-cnt reg)) (1-(+ bit-cnt (nth 1 elm))) bit-cnt)
                     (incf bit-cnt (nth 1 elm))
                     )))
                 )
               reg)
          (format s "          end~%")
          (format s "        end~%")
          (format s1 
"  }f;
}pannel_t_w~d;
"
                  word-cnt)
          (push (with-output-to-string (s2) (format s2 "pannel_t_w~d t_w~d" word-cnt word-cnt)) c-typedef-words)
          ))
      (format s "      endcase~%")
      (format s "    end~%")
      (format s "  end~%")
      (format s "end~%")
      (setf c-typedef-words (reverse c-typedef-words))
      (format s1 
"
typedef struct
{~{~% volatile ~A;~}
}pannel_t;
"
              c-typedef-words)
      (format s "~%")))
      ))
  )

(defun addr0-of (name)
  (let ((r nil))
    (map 'list
         (lambda (elm)
           (if (equalp (car elm) name)
             (setf r (nth 1 elm)))
           )
         *memory-map*)
    r))


(defun addr1-of (name)
  (let ((r nil))
    (map 'list
         (lambda (elm)
           (if (equalp (car elm) name)
             (setf r (nth 2 elm)))
           )
         *memory-map*)
    r))


(defun print-addr-define (s)
  (map 'list
       (lambda (dev)
         (if (and
               (listp dev)
               (stringp (car dev))
               )
           (let ((as (car dev))
                 (ref (nth 1 dev)))
             ;(format t "dev: ~S~%" dev)
             (map 'list
                  (lambda (elm)
                    (if (and
                          (listp elm)
                          (equalp (car elm) 'slave)
                          )
                      (let ((p (nth 2 elm)))
                        (map 'list
                             (lambda (bus)
                               (let*((id (string+ bus"_"as"_"p))
                                     (a0 (addr0-of id)))
                                 (if a0 
                                   (let ()
                                     (format s "#define ~20A 0x~8,'0x~%" (sym+ id"a0") a0)
                                     (format s "#define ~20A ((volatile ~20A *) ~20A)~%" (string-trim '(#\_)  id) (string+ ref"_t") (sym+ id"a0"))
                                     ))
                                 ))
                             (nth 1 elm)))))
                  (cddr dev)))))
       *place-list*))


(defun print-ld-script (s)
  (format s 
"
ENTRY(_start)
MEMORY
{
  ROM (rx ) : ORIGIN = 0x~8,'0x, LENGTH = 0x~8,'0x 
  RAM (rwx) : ORIGIN = 0x~8,'0x, LENGTH = 0x~8,'0x 
  DEV (rw ) : ORIGIN = 0x~8,'0x, LENGTH = 0x~8,'0x 
}

SECTIONS
{
  .text : 
  { 
    __text_start = .;
    *(.text.entry)
    *(.text .text.*)
    __text_end = .;
  } > ROM
  .rodata : 
  {
    __rodata_start = .;
    *(.rodata .rodata.*)
    __rodata_end = .;
  } > ROM
  .data : 
  { 
    __data_start = .;
    *(.data .data.*)
    __data_end = .;
  } > RAM
  _data_load = LOADADDR(.data);
  .bss : 
  { 
    __bss_start = .;
    *(.bss .bss.*)
    *(COMMON)
    __bss_end = .;
  } > RAM
  __heap_start = .;
  __heap_end = ORIGIN(RAM) + LENGTH(RAM) - 0x100;
  __stack_start = ORIGIN(RAM) + LENGTH(RAM) - 4;
  __stack_size = 0x100;
  __stack_end = __stack_start - __stack_size;
  .tdata :
  {
    __tdata_start = .;
    *(.tdata .tdata.*)
  } > RAM 
  .tbss : 
  {
    __tbss_start = .;
    *(.tbss .tbss.*)
    __tbss_end = .;
  } > RAM 
  __executable_start = ORIGIN(ROM);
  _end = .;
}
"
          *rom-addr0* (+ 4 (- *rom-addr1* *rom-addr0*))
          *ram-addr0* (+ 4 (- *ram-addr1* *ram-addr0*))
          *dev-addr0* (+ 4 (- *dev-addr1* *dev-addr0*))
          ))

(defun synthesis (&key tmp.v interconnect.vh pannel.h pannel-in-bus-list first-ram last-ram bus.ld bus.h)
(let ((place-list (list))
      (clk nil)
      (rstb nil))
(with-fp-w (f tmp.v)
(setf place-list *place-list*)
(setf clk *clk*)
(setf rstb *rstb*)
(connect f)
(place f)
)
(setf 
  place-list 
  (append 
    place-list 
    (list 
      (list "pannel" "pannel" 
            (list 'slave 
                  pannel-in-bus-list ;(remove-duplicates (mapcar 'car *bus-list*) :test 'equalp);'("data0" "data1") 
                  "" (* 4 (length *pannel-word-list*)))))))
(clear)
(setf *place-list* place-list)
(setf *clk* clk)
(setf *rstb* rstb)
(with-fp-w (f interconnect.vh)
(connect f)
(place f)
)
(setf *place-list* place-list)
(with-fp-w (f pannel.h) (format f "~A" *pannel-c-typedef*))
(if bus.h (with-fp-w (f bus.h) (print-addr-define f)))
(if (and
      first-ram
      last-ram
      bus.ld
      )
  (let ()
    (setf *rom-addr0* 0)
    (setf *rom-addr1* (- (addr0-of first-ram) 4))
    (setf *ram-addr0* (addr0-of first-ram))
    (setf *ram-addr1* (addr1-of last-ram))
    (setf *dev-addr0* (+ (addr1-of last-ram) 4))
    (setf *dev-addr1* (- *addr* 4))
    (with-fp-w
      (f bus.ld)
      (print-ld-script f)
      )
    ))
)
)




