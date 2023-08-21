import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';
import 'package:sudoku/blockChar.dart';
import 'package:sudoku/boxInner.dart';
import 'package:sudoku/focusClass.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

import 'enum.dart';

class SudokuWidget extends StatefulWidget {
  const SudokuWidget({super.key});

  @override
  State<SudokuWidget> createState() => _SudokuWidgetState();
}

class _SudokuWidgetState extends State<SudokuWidget> {
  List<BoxInner> boxInners = [];
  FocusClass focusClass = FocusClass();
  bool isFinished = false;
  String? tapBoxIndex;

  @override
  void initState() {
    generateSudoku();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                height: 70,
                alignment: Alignment.bottomCenter,
                child: const Text(
                  'Sudoku',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  onPressed: () => generateSudoku(),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  width: double.maxFinite,
                  alignment: Alignment.topCenter,
                  child: GridView.builder(
                    itemCount: boxInners.length,
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                    ),
                    physics: const ScrollPhysics(),
                    itemBuilder: (buildContext, index) {
                      BoxInner boxInner = boxInners[index];
                      return Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: GridView.builder(
                          itemCount: boxInner.blockChars.length,
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                          ),
                          physics: const ScrollPhysics(),
                          itemBuilder: (buildContext, indexChar) {
                            BlockChar blockChar = boxInner.blockChars[indexChar];
                            Color color = Colors.white;
                            Color colorText = Colors.black;

                            if (isFinished) {
                              color = Colors.green;
                            } else if (blockChar.isDefault) {
                              color = Colors.grey.shade300;
                            } else if (blockChar.isFocus) {
                              color = Colors.brown.shade200;
                            }
                            if (tapBoxIndex == '$index-$indexChar' && !isFinished) {
                              color = Colors.blue.shade100;
                            } else if (blockChar.isExist) {
                              colorText = Colors.red;
                            }
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blueAccent,
                                ),
                                color: color,
                              ),
                              alignment: Alignment.center,
                              child: TextButton(
                                onPressed: blockChar.isDefault
                                    ? null
                                    : () => setFocus(
                                          index,
                                          indexChar,
                                        ),
                                child: Text(
                                  "${blockChar.text}",
                                  style: TextStyle(
                                    color: colorText,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      SizedBox(
                        child: GridView.builder(
                          itemCount: 9,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 9,
                            childAspectRatio: 1,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                          ),
                          physics: const ScrollPhysics(),
                          itemBuilder: (buildContext, index) {
                            return InkWell(
                              onTap: () => setInputs(index + 1),
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        width: 100,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => setInputs(null),
                          child: const Center(
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int empty(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  generatePuzzle() {
    boxInners.clear();
    print(empty(20, 50));
    var sudokuGenerator = SudokuGenerator(emptySquares: empty(20, 50));

    List<List<List<int>>> completes =
        partition(sudokuGenerator.newSudokuSolved, sqrt(sudokuGenerator.newSudoku.length).toInt()).toList();
    partition(sudokuGenerator.newSudoku, sqrt(sudokuGenerator.newSudoku.length).toInt())
        .toList()
        .asMap()
        .entries
        .forEach(
      (entry) {
        List<int> tempListCompletes = completes[entry.key].expand((element) => element).toList();
        List<int> tempList = entry.value.expand((element) => element).toList();

        tempList.asMap().entries.forEach((entryIn) {
          int index = entry.key * sqrt(sudokuGenerator.newSudoku.length).toInt() + (entryIn.key % 9).toInt() ~/ 3;

          if (boxInners.where((element) => element.index == index).isEmpty) {
            boxInners.add(BoxInner(index, []));
          }

          BoxInner boxInner = boxInners.where((element) => element.index == index).first;

          boxInner.blockChars.add(BlockChar(
            text: entryIn.value == 0 ? "" : entryIn.value.toString(),
            index: boxInner.blockChars.length,
            isDefault: entryIn.value != 0,
            isCorrect: entryIn.value != 0,
            correctText: tempListCompletes[entryIn.key].toString(),
          ));
        });
      },
    );
  }

  setFocus(int index, int indexChar) {
    tapBoxIndex = "$index-$indexChar";
    focusClass.setData(index, indexChar);
    showFocusCenterLine();
    setState(() {});
  }

  generateSudoku() {
    isFinished = false;
    focusClass = FocusClass();
    tapBoxIndex = null;
    generatePuzzle();
    checkFinish();
    setState(() {});
  }

  checkFinish() {
    int totalUnfinished =
        boxInners.map((e) => e.blockChars).expand((element) => element).where((element) => !element.isCorrect).length;

    isFinished = totalUnfinished == 0;
  }

  showFocusCenterLine() {
    int rowNoBox = focusClass.indexBox! ~/ 3;
    int colNoBox = focusClass.indexBox! % 3;

    for (var element in boxInners) {
      element.clearFocus();
    }

    boxInners
        .where((element) => element.index ~/ 3 == rowNoBox)
        .forEach((e) => e.setFocus(focusClass.indexChar!, Direction.Horizontal));

    boxInners
        .where((element) => element.index % 3 == colNoBox)
        .forEach((e) => e.setFocus(focusClass.indexChar!, Direction.Vertical));
  }

  setInputs(int? number) {
    if (focusClass.indexBox == null) return;
    if (boxInners[focusClass.indexBox!].blockChars[focusClass.indexChar!].text == number.toString() || number == null) {
      for (var element in boxInners) {
        element.clearFocus();
        element.clearExist();
      }
      boxInners[focusClass.indexBox!].blockChars[focusClass.indexChar!].setEmpty();
      tapBoxIndex = null;
      isFinished = false;
      showSameInputOnSameLine();
    } else {
      boxInners[focusClass.indexBox!].blockChars[focusClass.indexChar!].setText("$number");

      showSameInputOnSameLine();

      checkFinish();
    }

    setState(() {});
  }

  showSameInputOnSameLine() {
    int rowNoBox = focusClass.indexBox! ~/ 3;
    int colNoBox = focusClass.indexBox! % 3;

    String textInput = boxInners[focusClass.indexBox!].blockChars[focusClass.indexChar!].text!;

    for (var element in boxInners) {
      element.clearExist();
    }

    boxInners
        .where((element) => element.index ~/ 3 == rowNoBox)
        .forEach((e) => e.setExistValue(focusClass.indexChar!, focusClass.indexBox!, textInput, Direction.Horizontal));

    boxInners
        .where((element) => element.index % 3 == colNoBox)
        .forEach((e) => e.setExistValue(focusClass.indexChar!, focusClass.indexBox!, textInput, Direction.Vertical));

    List<BlockChar> exists = boxInners
        .map((element) => element.blockChars)
        .expand((element) => element)
        .where((element) => element.isExist)
        .toList();

    if (exists.length == 1) exists[0].isExist = false;
  }
}
