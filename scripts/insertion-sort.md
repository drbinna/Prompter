# Insertion Sort, Line by Line

## Refresher: what an algorithm is

**Say:** Quick refresher before we type anything. An algorithm is a step-by-step procedure that takes some input and turns it into some output. A recipe is an algorithm: ingredients in, cake out. The steps have to be precise enough that anyone, or any computer, could follow them and get the same result.

**Say:** Sorting is one of the classic problems algorithms solve. The input is a list of numbers in any order. The output is the same numbers, rearranged from smallest to largest. Same values, new order. That's the whole contract.

**Say:** There are lots of algorithms that sort. Insertion sort is the simplest one that's actually useful, and it's the one you already do by hand. When you pick up playing cards one at a time and slide each new card into the right place among the ones you're holding, that's insertion sort. The cards in your hand stay sorted the whole time, and each new card just finds its spot.

**Say:** So the idea is: take the cards one by one, and for each card, look left through the ones you've already sorted until you find where it belongs, shift the bigger ones over, and put it down. We're going to write exactly that in C. Seven lines. I'll type each one and tell you what it does.

## The code, line by line

### 1. The loop

**Type:** `for (int i = 1; i < n; i++) {`

**Say:** This loop walks through the cards on the table. `i` is a position in the array. It starts at 1, not 0, because the first card is already in my hand and one card is already sorted. `i < n` keeps us inside the array, and `i++` moves to the next card each round.

### 2. Pick up the card

**Type:** `int key = A[i];`

**Say:** The right hand picks up the card at position `i` and we call it `key`. We copy it out of the array into its own variable, because in a second we're going to overwrite that spot.

### 3. Look at the card to the left

**Type:** `int j = i - 1;`

**Say:** `j` is a second position. It points at the card just to the left of where key came from, the last card in my left hand. `i` moves forward through the deck. `j` is going to walk backward through my hand.

### 4. The question

**Type:** `while (j >= 0 && A[j] > key) {`

**Say:** This is the heart of it. Keep going while two things are true: there's still a card at `j`, and that card is bigger than key. The 5 is bigger than the 2, so we go in. And notice the order. The `j >= 0` check comes first, so if j ever goes past the left edge, C stops before it tries to read `A[-1]`. Swap those two and the program reads memory that doesn't exist.

### 5. Slide the bigger card right

**Type:** `A[j + 1] = A[j];`

**Say:** The 5 is bigger, so it slides one spot to the right to make room. For a moment A[0] and A[1] are both 5. That's just what copying does, and it's why we saved the 2 in key first. Otherwise it would be gone.

### 6. Move one card left

**Type:** `j--;`

**Say:** `j--` means `j = j - 1`. j was 0, now it's -1. There's no card there, so the next time the while loop asks its question, `j >= 0` is false and the loop stops.

**Type:** `}` on its own line to close the while loop.

**Say:** That brace closes the while. Everything inside it repeats. Everything after it runs once per card.

### 7. Put the card down

**Type:** `A[j + 1] = key;`

**Say:** The loop stopped, and the gap is right where key belongs: one spot to the right of j. j is -1, so j + 1 is 0. The 2 goes into A[0], and my left hand is sorted again. Two cards now.

**Type:** `}` to close the for loop.

**Say:** And that's the whole function. Pick up a card, look left, slide the bigger cards over, drop it in the gap, next card.

## The finished function

```c
void insertion_sort(int A[], int n) {
    for (int i = 1; i < n; i++) {
        int key = A[i];
        int j = i - 1;
        while (j >= 0 && A[j] > key) {
            A[j + 1] = A[j];
            j--;
        }
        A[j + 1] = key;
    }
}
```
