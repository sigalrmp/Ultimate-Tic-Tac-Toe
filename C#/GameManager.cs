using System;
using System.Collections;
using System.Collections.Generic;

public class GameManager
{
    static Tools.piece playerPiece;
    static Tools.piece AIPiece;
    static UltimateAI AI;
    static UltimateBoard board;

    static void Main(string[] args)
    {
        startGame();
    }

    private static void startGame()
    {
        board = new UltimateBoard();
        Console.WriteLine("would you like to be x or o?");
        string player = Console.ReadLine();
        if (player.Equals("x") || player.Equals("X"))
            (playerPiece, AIPiece) = (Tools.piece.x, Tools.piece.o);
        else if (player.Equals("o") || player.Equals("O"))
            (playerPiece, AIPiece) = (Tools.piece.o, Tools.piece.x);
        else { Console.WriteLine(Tools.invalidAnswerChoice); startGame(); }
        Console.WriteLine("what level would you like to play at; easy, medium, hard or expert? (expert will be slow)");
        string level = Console.ReadLine();
        if (level.Equals("easy") || level.Equals("Easy")) AI = new UltimateAI(board, Tools.easyDepth, AIPiece);
        else if (level.Equals("medium") || level.Equals("Medium")) AI = new UltimateAI(board, Tools.mediumDepth, AIPiece);
        else if (level.Equals("hard") || level.Equals("Hard")) AI = new UltimateAI(board, Tools.hardDepth, AIPiece);
        else if (level.Equals("expert") || level.Equals("Expert")) AI = new UltimateAI(board, Tools.expertDepth, AIPiece);
        else { Console.WriteLine(Tools.invalidAnswerChoice); startGame(); }
        gameplay(Tools.piece.x, null);
    }

    private static void gameplay(Tools.piece turn, Tools.move lastMove)
    {
        printBoard();
        /*if (!(lastMove is null))
        {
            Console.WriteLine("finished: " + board.boardIsFinished(lastMove.getMiniRow, lastMove.getMiniCol));
            MiniBoard lilBoard = board.getBoard()[lastMove.getMiniRow][lastMove.getMiniCol];
            Console.WriteLine("x score in " + Tools.rowColToBoard(lastMove.getMiniRow, lastMove.getMiniCol) + ": " + lilBoard.score(Tools.piece.x));
            Console.WriteLine("o score in " + Tools.rowColToBoard(lastMove.getMiniRow, lastMove.getMiniCol) + ": " + lilBoard.score(Tools.piece.o));
        }*/
        if (board.isFinished()) endGame();
        else
        {
            if (turn == playerPiece)
            {
                gameplay(AIPiece, playerMove(lastMove));
            }
            else if (turn == AIPiece)
            {
                // Console.WriteLine("AI playing");
                gameplay(playerPiece, AI.nextMove(lastMove));
            }
            else throw Tools.invalidPlayer;
        }
    }

    // finds, excecutes, and returns move
    private static Tools.move playerMove(Tools.move lastMove)
    {
        bool chooseBoard = false;
        if (lastMove is null) chooseBoard = true;
        else if (board.boardIsFinished(lastMove.getMiniRow, lastMove.getMiniCol)) chooseBoard = true;
        int bigRow;
        int bigCol;
        if (chooseBoard)
        {
            (bigRow, bigCol) = playerMoveH("which board would you like to play on? (type 'help' to find options)");
            if (board.boardIsFinished(bigRow, bigCol))
            {
                Console.WriteLine("that board is finished and connot be played on");
                return playerMove(lastMove);
            }
        }
        else
        {
            (bigRow, bigCol) = (lastMove.getMiniRow, lastMove.getMiniCol);
            Console.WriteLine("you are playing in the " + Tools.rowColToBoard(bigRow, bigCol) + " board");
        }
        (int miniRow, int miniCol) = playerMoveH("which space would you like to play on? (type 'help' to find options)");
        Tools.move nextMove = new Tools.move(bigRow, bigCol, miniRow, miniCol);
        if (board.getSpace(nextMove) != Tools.piece.empty)
        {
            Console.WriteLine("that space is not available");
            return playerMove(lastMove);
        }
        board.setSpace(nextMove, playerPiece);
        return nextMove;
    }

    private static (int, int) playerMoveH(string message)
    {
        Console.WriteLine(message);
        string choice = Console.ReadLine();
        if (choice.Equals("help") || choice.Equals("Help")) { Console.WriteLine(Tools.key); return playerMoveH(message); }
        if (choice.Equals("tl") || choice.Equals("TL") || choice.Equals("Tl")) return (0, 0);
        if (choice.Equals("tc") || choice.Equals("TC") || choice.Equals("Tc")) return (0, 1);
        if (choice.Equals("tr") || choice.Equals("TR") || choice.Equals("Tr")) return (0, 2);
        if (choice.Equals("cl") || choice.Equals("CL") || choice.Equals("Cl")) return (1, 0);
        if (choice.Equals("cc") || choice.Equals("CC") || choice.Equals("Cc")) return (1, 1);
        if (choice.Equals("cr") || choice.Equals("CR") || choice.Equals("Cr")) return (1, 2);
        if (choice.Equals("bl") || choice.Equals("BL") || choice.Equals("Bl")) return (2, 0);
        if (choice.Equals("bc") || choice.Equals("BC") || choice.Equals("Bc")) return (2, 1);
        if (choice.Equals("br") || choice.Equals("BR") || choice.Equals("Br")) return (2, 2);
        else { Console.WriteLine(Tools.invalidAnswerChoice); return playerMoveH(message); }
    }

    public static void endGame()
    {
        Tools.piece winner = board.getWinner();
        if (winner == playerPiece) Console.WriteLine("Congratulations, you won!");
        else if (winner == Tools.piece.empty) Console.Write("You tied this game.");
        else Console.WriteLine("You lost this game. Better luck next time!");
        Console.WriteLine("Would you like to try again? (y/n)");
        string restart = Console.ReadLine();
        if (restart.Equals("y") || restart.Equals("Y")) startGame();
        else if (restart.Equals("n") || restart.Equals("N"))
            Console.WriteLine("I hope you had fun!");
        else throw Tools.invalidAnswerChoice;
    }

    public static void printBoard()
    {
        Console.WriteLine("\n");
        printBoardH(0);
    }

    public static void printBoardH(int row)
    {
        if (row <= 11)
        {
            if ((row + 1) % 4 == 0) { Console.WriteLine("\n"); printBoardH(row + 1); }
            else
            {
                string rowPrint = "";
                int bigRow = 0;
                int miniRow = row;
                if (row > 2) { bigRow = 1; miniRow -= 1; }
                if (row > 6) { bigRow = 2; miniRow -= 1; }
                miniRow %= 3;
                foreach (MiniBoard miniBoard in board.getBoard()[bigRow])
                {
                    foreach (Tools.piece space in miniBoard.getBoard()[miniRow])
                    {
                        string spacePrint;
                        if (space == Tools.piece.empty)
                            spacePrint = "- ";
                        else spacePrint = space + " ";
                        rowPrint += spacePrint;
                    }
                    rowPrint += "  ";
                }
                Console.WriteLine(rowPrint);
                printBoardH(row + 1);
            }
        }
    }
}