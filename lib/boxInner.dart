import 'package:sudoku/blockChar.dart';
import 'package:sudoku/enum.dart';

class BoxInner {
  late int index;
  List<BlockChar> blockChars = List<BlockChar>.from([]);

  BoxInner(this.index, this.blockChars);

  setFocus(int index, Direction direction) {
    List<BlockChar> temp;

    if (direction == Direction.Horizontal) {
      temp = blockChars
          .where(
            (element) => element.index! ~/ 3 == index ~/ 3,
      )
          .toList();
    } else {
      temp = blockChars
          .where(
            (element) => element.index! % 3 == index % 3,
      )
          .toList();
    }

    for (var element in temp) {
      element.isFocus = true;
    }
  }

  setExistValue(int index, int indexBox, String textInput, Direction direction) {
    List<BlockChar> temp;

    if (direction == Direction.Horizontal) {
      temp = blockChars
          .where(
            (element) => element.index! ~/ 3 == index ~/ 3,
      )
          .toList();
    } else {
      temp = blockChars
          .where(
            (element) => element.index! % 3 == index % 3,
      )
          .toList();
    }

    if (this.index == indexBox) {
      List<BlockChar> blockCharsBox = blockChars
          .where(
            (element) => element.text == textInput,
      )
          .toList();

      if (blockCharsBox.length == 1 && temp.isEmpty) {
        blockCharsBox.clear();
      }

      temp.addAll(blockCharsBox);
    }

    temp.where((element) => element.text == textInput).forEach((element) {
      element.isExist = true;
    });
  }

  clearFocus() {
    for (var element in blockChars) {
      element.isFocus = false;
    }
  }

  clearExist() {
    for (var element in blockChars) {
      element.isExist = false;
    }
  }
}
