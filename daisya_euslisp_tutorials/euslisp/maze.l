;;
;; ��ϩ�ꥹ�Ȥ�����ϩ��ǥ����������
;;   2009/11/14 written by nakanish
;;
(load "psolve.l")
;;
(setq *m*
      '((1 2) (2 3) (3 4) (4 9) (9 14) (9 8)
	(8 7) (7 12) (12 13) (12 11) (11 6)
	(11 16) (14 15) (16 17) (17 22)
	(21 22) (22 23) (23 18) (23 24)
	(24 19) (19 20) (20 15) (15 10)
	(10 5) (20 25)))
;;
;; *m*������ϩmodel����
;; 
;; 1 2 3
;; 4 5 6
;; 7 8 9
;; 
;; �Τ褦�ʳʻ���ϩ���ꤹ��
;;
(defun make-maze
  (maze-list
   &key (row-num 5)       ;;�� = x������Ĺ��
   (column-num 5)    ;;�� = y������Ĺ��
   (maze-length 470.0) ;;��ϩ��1�ʻҤ�Ĺ��
   (maze-height 150.0)
   (remove-wall-list nil) ;;���ꤷ����ɸ���ɤ������ (list '((0 0) (0 1)) ...)
   )
  (let (kousi-graph-list ;;�ʻҺ�ɸ̵������դΥꥹ��(��ϩ���ɤ�ɽ��)
	bs maze rm-graph)
    (setq maze-length (float maze-length))
    ;;�Ȥꤢ�������Ƥ��ɥ���եꥹ�Ȥ���
    (dotimes (i row-num)
      (dotimes (j (1+ column-num))
	(push (list (list (* maze-length i) (* maze-length j))
		    (list (* maze-length (1+ i)) (* maze-length j)))
	      kousi-graph-list)))
    (dotimes (i (1+ row-num))
      (dotimes (j column-num)
	(push (list (list (* maze-length i) (* maze-length j))
		    (list (* maze-length i) (* maze-length (1+ j))))
	      kousi-graph-list)))
    ;;Ϳ����줿��ϩ�ѥ������ɥ���դ������Ƥ���
    (dolist (m maze-list)
      (setq rm-graph
	    (generate-kousi-graph m :row-num row-num :column-num column-num :maze-length maze-length))
      (setq kousi-graph-list
	    (remove-if #'(lambda (x) 
			   ;;(print x)
			   ;;(print rm-graph)
			   (set= x rm-graph :test #'equal))
			   kousi-graph-list))
      )
    ;;when remove-wall-list
    (dolist (remove-wall remove-wall-list)
      (setq rm-graph
	    (list (mapcar #'(lambda (x) (* x maze-length)) (car remove-wall))
		  (mapcar #'(lambda (x) (* x maze-length)) (cadr remove-wall))))
      (setq kousi-graph-list
	    (remove-if #'(lambda (x) 
			   (set= x rm-graph :test #'equal))
			   kousi-graph-list)))
    (setq bs (make-maze-bodies kousi-graph-list 
			       :height maze-height))
    (dolist (b (cdr bs)) (send (car bs) :assoc b))
    (dolist (b bs) (send b :worldcoords))
    (setq maze (instance bodyset :init (make-cascoords) :bodies bs :name :maze))
    ;;
    ;;maze�˾�����ղä��Ƥ���
    (setf (get maze :column-num) column-num)
    (setf (get maze :row-num) column-num)
    (setf (get maze :maze-length) maze-length)
    (setf (get maze :maze-height) maze-height)
    (setf (get maze :maze-list) maze-list)
    maze))
;;
;; ��ϩ��̵������դ��鳺�������ɥ���դ���������
;;
(defun generate-kousi-graph
  (maze-graph 
   &key
   (row-num 5)       ;;�� = x������Ĺ��
   (column-num 5)    ;;�� = y������Ĺ��
   (maze-length 470) ;;��ϩ��1�ʻҤ�Ĺ��
   )
  (let* ((xy0 (generate-list-from-nodenum (car maze-graph) :column-num column-num :maze-length maze-length))
	 (xy1 (generate-list-from-nodenum (cadr maze-graph) :column-num column-num :maze-length maze-length))
	 ret
	 )
    (cond 
     ((= (car xy0) (car xy1)) ;;x��ɸ��Ʊ���Ȥ�
      (setq ret
	    (list (list (- (car xy0) (* 0.5 maze-length)) (* 0.5 (+ (cadr xy0) (cadr xy1))))
		  (list (+ (car xy0) (* 0.5 maze-length)) (* 0.5 (+ (cadr xy0) (cadr xy1)))))))
     ((= (cadr xy0) (cadr xy1)) ;;y��ɸ��Ʊ���Ȥ�
      (setq ret
	    (list (list (* 0.5 (+ (car xy0) (car xy1))) (- (cadr xy0) (* 0.5 maze-length)))
		  (list (* 0.5 (+ (car xy0) (car xy1))) (+ (cadr xy0) (* 0.5 maze-length))))))
     (t
      (warn "no such graph~%")))
    ret))
;;
;; ��ϩ��node�ֹ椫���ɸ��x y�ˤ�����
;;  (node�ֹ��1���饹�����ȤȤ���)
(defun generate-list-from-nodenum
  (nodeno
   &key
   (column-num 5)    ;;�� = y������Ĺ��
   (maze-length 470) ;;��ϩ��1�ʻҤ�Ĺ��
   )
  (list 
   (* maze-length (+ 0.5 (/ (1- nodeno) column-num)))
   (* maze-length (+ 0.5 (mod (1- nodeno) column-num)))
   ))
(defun generate-coords-from-nodenum
  (nodeno &key (column-num 5) (maze-length 470))
  (let* ((l (generate-list-from-nodenum 
             nodeno 
             :column-num column-num
             :maze-length maze-length))
	 (c (float-vector 0 0 0))
	 )
    (dotimes (i 2) (setf (aref c i) (elt l i)))
    c
    ))
;;
;;�ʻҺ�ɸ̵������դΥꥹ�Ȥ����ɤ���
(defun make-maze-bodies
  (kousi-graph-list 
   &key 
   (height 100)
   (color :blue)
   (width 5)
   )
  (let (bs b x y x0 y0)
    (dolist (kousi-graph kousi-graph-list)
      ;;start��ɸ�����
      (setq x0 (car (car kousi-graph))
	    y0 (cadr (car kousi-graph)))
      ;;x,y�����
      (setq x (max (- (car (cadr kousi-graph)) (car (car kousi-graph))) width)
	    y (max (- (cadr (cadr kousi-graph)) (cadr (car kousi-graph))) width))
      ;;�ɤ���������
      (setq b (make-cube x y height))
      ;;�ɤ����֤���
      (cond
       ((> x y) ;;x�������ɤʤ��
	(send b :locate (float-vector (+ (* 0.5 x) x0) y0 (* 0.5 height))))
       (t
	(send b :locate (float-vector x0 (+ (* 0.5 y) y0) (* 0.5 height))))
       )
      (setf (get b :face-color) color)
      (push b bs)
      )
    bs))

  
  