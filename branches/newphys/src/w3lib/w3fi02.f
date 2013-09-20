      SUBROUTINE W3FI02(IN,IDEST,NUM)
C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM:    W3FI02      TRANSFERS ARRAY FROM 16 TO 64 BIT WORDS
C   PRGMMR: KEYSER           ORG: W/NMC22    DATE: 06-29-92
C
C ABSTRACT: TRANSFERS AN ARRAY OF NUMBERS FROM 16 BIT (IBM INTEGER*2)
C   IBM HALF-WORDS TO DEFAULT INTEGERS.
C
C PROGRAM HISTORY LOG:
C   92-06-29  D. A. KEYSER (W/NMC22)
C   98-11-17  Gilbert       Removed Cray references
C
C USAGE:    CALL W3FI02(IN,IDEST,NUM)
C   INPUT ARGUMENT LIST:
C     IN       - STARTING ADDRESS FOR ARRAY OF 16 BIT IBM HALF-WORDS
C     NUM      - NUMBER OF NUMBERS IN 'IN' TO TRANSFER.
C
C   OUTPUT ARGUMENT LIST:      (INCLUDING WORK ARRAYS)
C     IDEST    - STARTING ADDRESS FOR ARRAY OF OUTPUT INTEGERS
C
C   SUBPROGRAMS CALLED:
C     LIBRARY:
C       NONE
C
C REMARKS: THIS IS THE INVERSE OF LIBRARY ROUTINE W3FI03.
C
C ATTRIBUTES:
C   LANGUAGE: IBM XL FORTRAN 
C   MACHINE:  IBM SP
C
C$$$
C
      INTEGER(2)  IN(*)
      INTEGER  IDEST(*)
C
      SAVE
C
C      CALL USICTC(IN,1,IDEST,NUM,2)
       IDEST(1:NUM)=IN(1:NUM)
C
      RETURN
      END
