package org.example
package text

import org.emmalanguage.api._
import org.emmalanguage.io.csv.CSV
import org.emmalanguage.test.util._
import org.scalatest.BeforeAndAfter
import org.scalatest.FlatSpec
import org.scalatest.Matchers

import java.io.File
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Paths

trait BaseWordCountIntegrationSpec extends FlatSpec with Matchers with BeforeAndAfter {

  val codegenDir = tempPath("codegen")
  val dir = "/text/"
  val path = tempPath(dir)
  val text = "To be or not to Be"

  before {
    new File(codegenDir).mkdirs()
    new File(path).mkdirs()
    addToClasspath(new File(codegenDir))
    Files.write(Paths.get(s"$path/hamlet.txt"), text.getBytes(StandardCharsets.UTF_8))
  }

  after {
    deleteRecursive(new File(codegenDir))
    deleteRecursive(new File(path))
  }

  "WordCount" should "count words" in {
    wordCount(s"$path/hamlet.txt", s"$path/output.txt", CSV())

    val act = DataBag(fromPath(s"$path/output.txt"))
    val exp = DataBag(text.toLowerCase.split("\\W+").groupBy(x => x).toSeq.map(x => s"${x._1}\t${x._2.length}"))

    compareBags(act.fetch(), exp.fetch())
  }

  def wordCount(input: String, output: String, csv: CSV): Unit
}
