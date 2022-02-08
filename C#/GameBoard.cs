using System;
using System.Collections;
using System.Collections.Generic;

public abstract class GameBoard
{
    private IEnumerable[] board;

    protected GameBoard() { }

    protected GameBoard(IEnumerable[] board)
    {
        this.board = board;
    }

    protected void setBoard(IEnumerable[] board)
    {
        this.board = board;
    }

    public Tools.piece getWinner()
    {
        if (!isFinished()) throw Tools.notFinished;
        else if (score(Tools.piece.x) == 1) return Tools.piece.x;
        else if (score(Tools.piece.o) == 1) return Tools.piece.o;
        else return Tools.piece.empty;
    }

    public abstract bool isFinished();

    public double score(Tools.piece player)
    {
        double playerRawScore = genRawScore(player);
        double oppRawScore = genRawScore(Tools.getOpponent(player));
        if (playerRawScore == 1) return 1;
        return playerRawScore * (1 - oppRawScore) + Math.Pow(playerRawScore, 2) * oppRawScore / (playerRawScore + oppRawScore);
    }

    protected abstract double getMultiplyer(int row, int col, Tools.piece player);

    private double genRawScore(Tools.piece player)
    {
        return 1 - scoreHorizontal(player) * scoreVertical(player) * scoreDiagonal(player);
    }

    public double scoreHorizontal(Tools.piece player) //should be private
    {
        double score = 1;
        for (int row = 0; row < 3; row++)
        {
            double rowScore = 1;
            for (int col = 0; col < 3; col++)
            {
                rowScore *= getMultiplyer(row, col, player);
            }
            score *= 1 - rowScore;
        }
        return score;
    }

    private double scoreVertical(Tools.piece player)
    {
        double score = 1;
        for (int col = 0; col < 3; col++)
        {
            double colScore = 1;
            for (int row = 0; row < 3; row++)
            {
                colScore *= getMultiplyer(row, col, player);
            }
            score *= 1 - colScore;
        }
        return score;
    }

    private double scoreDiagonal(Tools.piece player)
    {
        double score1 = 1;
        double score2 = 1;
        for (int i = 0; i < 3; i++)
        {
            score1 *= getMultiplyer(i, i, player);
            score2 *= getMultiplyer(i, 2 - i, player);
        }
        return (1 - score1) * (1 - score2);
    }

}