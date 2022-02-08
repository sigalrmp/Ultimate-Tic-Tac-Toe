using System;
using System.Collections;
using System.Collections.Generic;

public class Tools
{
    public enum piece
    {
        x,
        o,
        empty
    }

    public enum opt
    {
        min,
        max
    }

    public const int easyDepth = 2;
    public const int mediumDepth = 4;
    public const int hardDepth = 5;
    public const int expertDepth = 7;

    public static piece getOpponent(piece piece)
    {
        if (piece == piece.empty) return piece.empty;
        if (piece == piece.x) return piece.o;
        else return piece.x;
    }

    public static string rowColToBoard(int row, int col)
    {
        if ((row, col) == (0, 0)) return "top left";
        if ((row, col) == (0, 1)) return "top center";
        if ((row, col) == (0, 2)) return "top right";
        if ((row, col) == (1, 0)) return "center left";
        if ((row, col) == (1, 1)) return "center center";
        if ((row, col) == (1, 2)) return "center right";
        if ((row, col) == (2, 0)) return "bottom left";
        if ((row, col) == (2, 1)) return "bottom center";
        if ((row, col) == (2, 2)) return "bottom right";
        else throw Tools.rowColOutOfRange;
    }

    public static string key = "'tl' : top left         'tc' : top center        'tr' : top right \n 'cl' : center left         'cc' : center center          'cr' : center right \n 'bl' : bottom left         'bc' : bottom center        'bl' : bottom left";

    public static Exception invalidBoard = new Exception("board must be 3 by 3");
    public static Exception notFinished = new Exception("board not finished");
    public static Exception emptyScoring = new Exception("cannot score for empty");
    public static Exception invalidDepth = new Exception("depth outside of range");
    public static Exception invalidPlayer = new Exception("player must be x or o, not empty");
    public static Exception rowColOutOfRange = new Exception("row/col is out of 0-2 range");
    public static Exception invalidAnswerChoice = new Exception("please choose one of the given anwer choices; your answer may be uppercase or lowercaswe but make sure to omit extra characters or spaces");

    public class move
    {

        private int row;
        private int col;
        private int miniRow;
        private int miniCol;

        public move(int row, int col, int miniRow, int miniCol)
        {
            if (0 <= row && row <= 2) this.row = row;
            else throw rowColOutOfRange;
            if (0 <= col && col <= 2) this.col = col;
            else throw rowColOutOfRange;
            if (0 <= miniRow && miniRow <= 2) this.miniRow = miniRow;
            else throw rowColOutOfRange;
            if (0 <= miniCol && miniCol <= 2) this.miniCol = miniCol;
            else throw rowColOutOfRange;
        }

        public int getRow => row;

        public int getCol => col;

        public int getMiniRow => miniRow;

        public int getMiniCol => miniCol;

    }
}