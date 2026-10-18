class HealthObject<T> {
  T content;

  HealthObject(this.content);

  T getContent() {
    return content;
  }

  void showInfo() {
    print('Gia tri: $content');
  }
}
