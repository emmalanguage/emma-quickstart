package org.example
package algorithms.text

import org.emmalanguage.api._
import org.emmalanguage.test.util._
import org.scalatest.BeforeAndAfter
import org.scalatest.FlatSpec
import org.scalatest.Matchers

import java.io.File

trait BaseWordCountIntegrationSpec extends FlatSpec with Matchers with BeforeAndAfter {

  val codegenDir = tempPath("codegen")
  val dir = "/text"
  val path = tempPath(dir)

  before {
    new File(codegenDir).mkdirs()
    new File(path).mkdirs()
    addToClasspath(new File(codegenDir))
    materializeResource(s"$dir/jabberwocky.txt")
  }

  after {
    deleteRecursive(new File(codegenDir))
    deleteRecursive(new File(path))
  }

  it should "count words" in {
    wordCount(s"$path/jabberwocky.txt", s"$path/wordcount-output.txt", CSV())

    val act = DataBag(fromPath(s"$path/wordcount-output.txt"))
    val exp = DataBag({
      val words = for {
        line <- fromPath(s"$path/jabberwocky.txt")
        word <- line.toLowerCase.split("\\W+")
        if word != ""
      } yield word

      for {
        (word, occs) <- words.groupBy(x => x).toSeq
      } yield s"$word\t${occs.length}"
    })

    act.collect() should contain theSameElementsAs exp.collect()
  }

  def wordCount(input: String, output: String, csv: CSV): Unit
}
