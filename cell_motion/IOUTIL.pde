void writeString(String s){
  String[] lines = loadStrings("rules.txt");
  String[] out = new String[lines.length+1];
  arrayCopy(lines, out);
  out[lines.length] = s;
  saveStrings("rules.txt", out);
  println(s);
}

void writeRule(int[] rule){
  int value=rule[0];
  for(int i=1;i<rule.length;++i){
    value<<=1;
    value += rule[i];
  }
  String ruleString = ""+rule[0];
  for(int i=1;i< rule.length;++i){
    ruleString = ruleString + ", "+rule[i];
  }
  
  //String[] out = {};
  //saveStrings("rules.txt", out);
  writeString(""+value+" : {"+ruleString+"}");
  //writeString("awesome ^");
}