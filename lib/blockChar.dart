class BlockChar {
  String? text;
  String? correctText;
  int? index;
  bool isFocus = false;
  bool isCorrect;
  bool isDefault;
  bool isExist = false;

  BlockChar({
    this.text,
    this.correctText,
    this.index,
    this.isCorrect = false,
    this.isDefault = false,
  });

  get isCorrectPos => correctText == text;

  setText(String text) {
    this.text = text;
    isCorrect = isCorrectPos;
  }

  setEmpty(){
    text = '';
    isCorrect = false;
  }
}
