using System;
using System.Collections;
using System.Collections.Generic;

public class MiniBoard : GameBoard
{

    private Tools.piece[][] board;

    public MiniBoard() : base()
    {
        initBoard();
        base.setBoard(board);
        Console.WriteLine("mini multiplyers: " +
        this.getMultiplyer(0, 0, Tools.piece.o));
        Console.WriteLine("mini score of empty: " + this.score(Tools.piece.o));
    }

    public MiniBoard(Tools.piece[][] board) : base(board)
    {
        if (board.Length == 3 && board[0].Length == 3) this.board = board.Clone() as Tools.piece[][];
        else throw Tools.invalidBoard;
    }

    public static Tools.piece[][] cloneBoard(Tools.piece[][] board)
    {
        Tools.piece[][] clone = new Tools.piece[3][];
        for (int row = 0; row < 3; row++)
        {
            clone[row] = new Tools.piece[3];
        }
        for (int row = 0; row < 3; row++)
        {
            for (int col = 0; col < 3; col++)
            {
                Tools.piece space = board[row][col];
                clone[row][col] = space;
            }
        }
        return clone;
    }

    public override bool isFinished()
    {
        bool full = true;
        foreach (Tools.piece[] row in board)
            foreach (Tools.piece space in row)
                if (space == Tools.piece.empty) full = false;
        return full || base.score(Tools.piece.x) == 1.0 || base.score(Tools.piece.o) == 1.0;
    }

    public Tools.piece getSpace(int row, int col) => board[row][col];

    public void setSpace(int row, int col, Tools.piece piece)
    {
        board[row][col] = piece;
    }

    public Tools.piece[][] getBoard() => board;

    protected override double getMultiplyer(int row, int col, Tools.piece player)
    {
        Tools.piece space = board[row][col];
        if (space == player) return 1;
        if (space == Tools.piece.empty) return 0.5;
        return 0;
    }

    private void initBoard()
    {
        board = new Tools.piece[3][];
        for (int r = 0; r < 3; r++)
        {
            board[r] = new Tools.piece[3];
        }
        for (int r = 0; r < 3; r++)
        {
            for (int c = 0; c < 3; c++)
            {
                board[r][c] = Tools.piece.empty;
            }
        }
    }
}