C-----------------------------------------------------------------------
      SUBROUTINE IXGB(LUGB,LSKIP,LGRIB,NLEN,NNUM,MLEN,CBUF)
C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C
C SUBPROGRAM: IXGB           MAKE INDEX RECORD
C   PRGMMR: IREDELL          ORG: W/NMC23     DATE: 95-10-31
C
C ABSTRACT: THIS SUBPROGRAM MAKES ONE INDEX RECORD.
C       BYTE 001-004: BYTES TO SKIP IN DATA FILE BEFORE GRIB MESSAGE
C       BYTE 005-008: BYTES TO SKIP IN MESSAGE BEFORE PDS
C       BYTE 009-012: BYTES TO SKIP IN MESSAGE BEFORE GDS (0 IF NO GDS)
C       BYTE 013-016: BYTES TO SKIP IN MESSAGE BEFORE BMS (0 IF NO BMS)
C       BYTE 017-020: BYTES TO SKIP IN MESSAGE BEFORE BDS
C       BYTE 021-024: BYTES TOTAL IN THE MESSAGE
C       BYTE 025-025: GRIB VERSION NUMBER
C       BYTE 026-053: PRODUCT DEFINITION SECTION (PDS)
C       BYTE 054-095: GRID DEFINITION SECTION (GDS) (OR NULLS)
C       BYTE 096-101: FIRST PART OF THE BIT MAP SECTION (BMS) (OR NULLS)
C       BYTE 102-112: FIRST PART OF THE BINARY DATA SECTION (BDS)
C       BYTE 113-172: (OPTIONAL) BYTES 41-100 OF THE PDS
C       BYTE 173-184: (OPTIONAL) BYTES 29-40 OF THE PDS
C       BYTE 185-320: (OPTIONAL) BYTES 43-178 OF THE GDS
C
C PROGRAM HISTORY LOG:
C   95-10-31  IREDELL
C   96-10-31  IREDELL   AUGMENTED OPTIONAL DEFINITIONS TO BYTE 320
C 2001-06-05  IREDELL   APPLY LINUX PORT BY EBISUZAKI
C
C USAGE:    CALL WRGI1R(LUGB,LSKIP,LGRIB,LUGI)
C   INPUT ARGUMENTS:
C     LUGB         INTEGER LOGICAL UNIT OF INPUT GRIB FILE
C     LSKIP        INTEGER NUMBER OF BYTES TO SKIP BEFORE GRIB MESSAGE
C     LGRIB        INTEGER NUMBER OF BYTES IN GRIB MESSAGE
C     NLEN         INTEGER LENGTH OF EACH INDEX RECORD IN BYTES
C     NNUM         INTEGER INDEX RECORD NUMBER TO MAKE
C   OUTPUT ARGUMENTS:
C     MLEN         INTEGER ACTUAL VALID LENGTH OF INDEX RECORD
C     CBUF         CHARACTER*1 (MBUF) BUFFER TO RECEIVE INDEX DATA
C
C SUBPROGRAMS CALLED:
C   GBYTEC       GET INTEGER DATA FROM BYTES
C   SBYTEC       STORE INTEGER DATA IN BYTES
C   BAREAD       BYTE-ADDRESSABLE READ
C
C ATTRIBUTES:
C   LANGUAGE: CRAY FORTRAN
C
C$$$
      CHARACTER CBUF(*)
      PARAMETER(LINDEX=112,MINDEX=320)
      PARAMETER(IXSKP=0,IXSPD=4,IXSGD=8,IXSBM=12,IXSBD=16,IXLEN=20,
     &          IXVER=24,IXPDS=25,IXGDS=53,IXBMS=95,IXBDS=101,
     &          IXPDX=112,IXPDW=172,IXGDX=184)
      PARAMETER(MXSKP=4,MXSPD=4,MXSGD=4,MXSBM=4,MXSBD=4,MXLEN=4,
     &          MXVER=1,MXPDS=28,MXGDS=42,MXBMS=6,MXBDS=11,
     &          MXPDX=60,MXPDW=12,MXGDX=136)
      CHARACTER CBREAD(MINDEX),CINDEX(MINDEX)
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C  INITIALIZE INDEX RECORD AND READ GRIB MESSAGE
      MLEN=LINDEX
      CINDEX=CHAR(0)
      CALL SBYTEC(CINDEX,LSKIP,8*IXSKP,8*MXSKP)
      CALL SBYTEC(CINDEX,LGRIB,8*IXLEN,8*MXLEN)
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C  PUT PDS IN INDEX RECORD
      ISKPDS=8
      IBSKIP=LSKIP
      IBREAD=ISKPDS+MXPDS
      CALL BAREAD(LUGB,IBSKIP,IBREAD,LBREAD,CBREAD)
      IF(LBREAD.NE.IBREAD) RETURN
      CINDEX(IXVER+1)=CBREAD(8)
      CALL SBYTEC(CINDEX,ISKPDS,8*IXSPD,8*MXSPD)
      CALL GBYTEC(CBREAD,LENPDS,8*ISKPDS,8*3)
      CALL GBYTEC(CBREAD,INCGDS,8*ISKPDS+8*7+0,1)
      CALL GBYTEC(CBREAD,INCBMS,8*ISKPDS+8*7+1,1)
      ILNPDS=MIN(LENPDS,MXPDS)
      CINDEX(IXPDS+1:IXPDS+ILNPDS)=CBREAD(ISKPDS+1:ISKPDS+ILNPDS)
      ISKTOT=ISKPDS+LENPDS
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C  PUT PDS EXTENSION IN INDEX RECORD
      IF(LENPDS.GT.MXPDS) THEN
        ISKPDW=ISKPDS+MXPDS
        ILNPDW=MIN(LENPDS-MXPDS,MXPDW)
        IBSKIP=LSKIP+ISKPDW
        IBREAD=ILNPDW
        CALL BAREAD(LUGB,IBSKIP,IBREAD,LBREAD,CBREAD)
        IF(LBREAD.NE.IBREAD) RETURN
        CINDEX(IXPDW+1:IXPDW+ILNPDW)=CBREAD(1:ILNPDW)
        ISKPDX=ISKPDS+(MXPDS+MXPDW)
        ILNPDX=MIN(LENPDS-(MXPDS+MXPDW),MXPDX)
        IBSKIP=LSKIP+ISKPDX
        IBREAD=ILNPDX
        CALL BAREAD(LUGB,IBSKIP,IBREAD,LBREAD,CBREAD)
        IF(LBREAD.NE.IBREAD) RETURN
        CINDEX(IXPDX+1:IXPDX+ILNPDX)=CBREAD(1:ILNPDX)
        MLEN=MAX(MLEN,IXPDW+ILNPDW,IXPDX+ILNPDX)
      ENDIF
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C  PUT GDS IN INDEX RECORD
      IF(INCGDS.NE.0) THEN
        ISKGDS=ISKTOT
        IBSKIP=LSKIP+ISKGDS
        IBREAD=MXGDS
        CALL BAREAD(LUGB,IBSKIP,IBREAD,LBREAD,CBREAD)
        IF(LBREAD.NE.IBREAD) RETURN
        CALL SBYTEC(CINDEX,ISKGDS,8*IXSGD,8*MXSGD)
        CALL GBYTEC(CBREAD,LENGDS,0,8*3)
        ILNGDS=MIN(LENGDS,MXGDS)
        CINDEX(IXGDS+1:IXGDS+ILNGDS)=CBREAD(1:ILNGDS)
        ISKTOT=ISKGDS+LENGDS
        IF(LENGDS.GT.MXGDS) THEN
          ISKGDX=ISKGDS+MXGDS
          ILNGDX=MIN(LENGDS-MXGDS,MXGDX)
          IBSKIP=LSKIP+ISKGDX
          IBREAD=ILNGDX
          CALL BAREAD(LUGB,IBSKIP,IBREAD,LBREAD,CBREAD)
          IF(LBREAD.NE.IBREAD) RETURN
          CINDEX(IXGDX+1:IXGDX+ILNGDX)=CBREAD(1:ILNGDX)
          MLEN=MAX(MLEN,IXGDX+ILNGDX)
        ENDIF
      ENDIF
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C  PUT BMS IN INDEX RECORD
      IF(INCBMS.NE.0) THEN
        ISKBMS=ISKTOT
        IBSKIP=LSKIP+ISKBMS
        IBREAD=MXBMS
        CALL BAREAD(LUGB,IBSKIP,IBREAD,LBREAD,CBREAD)
        IF(LBREAD.NE.IBREAD) RETURN
        CALL SBYTEC(CINDEX,ISKBMS,8*IXSBM,8*MXSBM)
        CALL GBYTEC(CBREAD,LENBMS,0,8*3)
        ILNBMS=MIN(LENBMS,MXBMS)
        CINDEX(IXBMS+1:IXBMS+ILNBMS)=CBREAD(1:ILNBMS)
        ISKTOT=ISKBMS+LENBMS
      ENDIF
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C  PUT BDS IN INDEX RECORD
      ISKBDS=ISKTOT
      IBSKIP=LSKIP+ISKBDS
      IBREAD=MXBDS
      CALL BAREAD(LUGB,IBSKIP,IBREAD,LBREAD,CBREAD)
      IF(LBREAD.NE.IBREAD) RETURN
      CALL SBYTEC(CINDEX,ISKBDS,8*IXSBD,8*MXSBD)
      CALL GBYTEC(CBREAD,LENBDS,0,8*3)
      ILNBDS=MIN(LENBDS,MXBDS)
      CINDEX(IXBDS+1:IXBDS+ILNBDS)=CBREAD(1:ILNBDS)
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C  STORE INDEX RECORD
      MLEN=MIN(MLEN,NLEN)
      NSKIP=NLEN*(NNUM-1)
      CBUF(NSKIP+1:NSKIP+MLEN)=CINDEX(1:MLEN)
      CBUF(NSKIP+MLEN+1:NSKIP+NLEN)=CHAR(0)
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      RETURN
      END
