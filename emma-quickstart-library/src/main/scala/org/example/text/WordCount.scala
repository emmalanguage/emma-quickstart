package org.example
package text

import org.emmalanguage.api._

@emma.lib
object WordCount {

  def apply(docs: DataBag[String]): DataBag[(String, Long)] = {
    val words = for {
      line <- docs
      word <- DataBag[String](line.toLowerCase.split("\\W+"))
      if word != ""
    } yield word

    // group the words by their identity and count the occurrence of each word
    val counts = for {
      group <- words.groupBy(identity)
    } yield (group.key, group.values.size)

    counts
  }
}
