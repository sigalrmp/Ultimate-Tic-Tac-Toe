using System;
using System.Collections;
using System.Collections.Generic;

public class UltimateAI
{
    private UltimateBoard board;
    private int depth;
    private Tools.piece me;
    private Tools.piece opp;
    private const int maxDepth = 9;

    public UltimateAI(UltimateBoard board, int depth, Tools.piece me)
    {
        this.board = board;
        if (depth <= maxDepth && depth > 0) this.depth = depth;
        else throw Tools.invalidDepth;
        if (me != Tools.piece.empty) this.me = me;
        else throw Tools.invalidPlayer;
        opp = Tools.getOpponent(me);
    }

    // exicutes move and returns the move that it makes
    public Tools.move nextMove(Tools.move lastMove)
    {
        Tools.move nextMove = nextMoveABPrune(me, board, lastMove, 0, 1, 0).Item2;
        board.setSpace(nextMove, me);
        Console.WriteLine("AI move: board - " + Tools.rowColToBoard(nextMove.getRow, nextMove.getCol) + ", space - " + Tools.rowColToBoard(nextMove.getMiniRow, nextMove.getMiniCol));
        return nextMove;
    }

    private (double, Tools.move) nextMoveABPrune(Tools.piece player, UltimateBoard board, Tools.move lastMove, int layer, double alpha, double beta)
    {
        Tools.opt opt = player == me ? Tools.opt.max : Tools.opt.min;
        double currentScore = board.score(me);
        if (layer == depth || board.isFinished()) return (currentScore, lastMove);
        List<Tools.move> moves = genAllMoves(board, lastMove);
        (double optScore, Tools.move optMove) = (0, null);
        if (opt == Tools.opt.min) optScore = 1;
        bool prune = false;
        foreach (Tools.move move in moves)
        {
            UltimateBoard nextBoard = new UltimateBoard(board.getBoard());
            nextBoard.setSpace(move, player);
            Tools.piece nextPlayer = Tools.getOpponent(player);
            double nextScore = nextMoveABPrune(nextPlayer, nextBoard, move, layer + 1, alpha, beta).Item1;
            //Console.WriteLine("board: " + Tools.rowColToBoard(move.getRow, move.getCol) + ", space: " + Tools.rowColToBoard(move.getMiniRow, move.getMiniCol) + ", score: " + nextScore);
            prune = timeToPruneAB(nextPlayer, nextScore, alpha, beta);
            if (prune)
            {
                (optScore, optMove) = (nextScore, move);
                break;
            }
            if (betterScore(opt, nextScore, optScore)) (optScore, optMove) = (nextScore, move);
            if (player == me && nextScore > beta) beta = nextScore;
            if (player == opp && nextScore < alpha) alpha = nextScore;
        }
        // update alpha/beta
        return (optScore, optMove);
    }

    private bool betterScore(Tools.opt opt, double score, double optScore)
    {
        return (opt == Tools.opt.min && score < optScore) || (opt == Tools.opt.max && score > optScore);
    }

    // returns whether it is time to prune and updates the alpha and beta vals
    private bool timeToPruneAB(Tools.piece player, double score, double alpha, double beta)
    {
        if (player == opp)
        {
            return score >= alpha;
        }
        else return score <= beta;
    }
    private List<Tools.move> genAllMoves(UltimateBoard board, Tools.move lastMove)
    {
        List<Tools.move> moves = new List<Tools.move>();
        for (int row = 0; row < 3; row++)
            for (int col = 0; col < 3; col++)
            {
                //if (lastMove is null) { moves.Add(new Tools.move(1, 1, 1, 1)); return moves; } // it is the first move
                bool chooseBoard = lastMove is null || board.boardIsFinished(lastMove.getMiniRow, lastMove.getMiniCol);
                if (chooseBoard)
                    for (int bigRow = 0; bigRow < 3; bigRow++)
                        for (int bigCol = 0; bigCol < 3; bigCol++)
                        {
                            Tools.move nextMove = new Tools.move(bigRow, bigCol, row, col);
                            if (board.getSpace(nextMove) == Tools.piece.empty && !board.boardIsFinished(bigRow, bigCol))
                                moves.Add(nextMove);
                        }
                else
                {
                    int bigRow = lastMove.getMiniRow;
                    int bigCol = lastMove.getMiniCol;
                    Tools.move nextMove = new Tools.move(bigRow, bigCol, row, col);
                    if (board.getSpace(nextMove) == Tools.piece.empty)
                        moves.Add(nextMove);
                }
            }
        return moves;
    }
}