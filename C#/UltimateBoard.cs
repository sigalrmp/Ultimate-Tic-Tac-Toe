using System;
using System.Collections;
using System.Collections.Generic;

public class UltimateBoard : GameBoard
{

    private MiniBoard[][] board;

    public UltimateBoard() : base()
    {
        initBoard();
        base.setBoard(board);
        Console.WriteLine("multiplyer of top left: " + getMultiplyer(0, 0, Tools.piece.o));
        Console.WriteLine("hor score:" + this.scoreHorizontal(Tools.piece.o));
    }

    public UltimateBoard(MiniBoard[][] board) : base(board)
    {
        if (board.Length == 3 && board[0].Length == 3) this.board = cloneBoard(board);
        else throw Tools.invalidBoard;
    }

    public static MiniBoard[][] cloneBoard(MiniBoard[][] board)
    {
        MiniBoard[][] clone = new MiniBoard[3][];
        for (int row = 0; row < 3; row++)
        {
            clone[row] = new MiniBoard[3];
        }
        for (int row = 0; row < 3; row++)
        {
            for (int col = 0; col < 3; col++)
            {
                clone[row][col] = new MiniBoard(MiniBoard.cloneBoard(board[row][col].getBoard()));
            }
        }
        return clone;
    }

    public override bool isFinished()
    {
        bool full = true;
        foreach (MiniBoard[] row in board)
            foreach (MiniBoard space in row)
                if (!space.isFinished()) full = false;
        return full || base.score(Tools.piece.x) == 1.0 || base.score(Tools.piece.o) == 1.0;
    }

    public Tools.piece getSpace(Tools.move move) => board[move.getRow][move.getCol].getSpace(move.getMiniRow, move.getMiniCol);

    public void setSpace(Tools.move move, Tools.piece piece)
    {
        board[move.getRow][move.getCol].setSpace(move.getMiniRow, move.getMiniCol, piece);
    }

    public bool boardIsFinished(int row, int col) => board[row][col].isFinished();

    public Tools.piece getBoardWinner(int row, int col) => board[row][col].getWinner();

    public MiniBoard[][] getBoard() => board;

    protected override double getMultiplyer(int row, int col, Tools.piece player)
    {
        return board[row][col].score(player);
    }

    private void initBoard()
    {
        board = new MiniBoard[3][];
        for (int r = 0; r < 3; r++)
        {
            board[r] = new MiniBoard[3];
        }
        for (int r = 0; r < 3; r++)
        {
            for (int c = 0; c < 3; c++)
            {
                board[r][c] = new MiniBoard();
            }
        }
    }
}