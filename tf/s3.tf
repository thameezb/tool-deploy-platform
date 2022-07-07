resource "aws_s3_bucket" "benchmark_results" {
  bucket = "ag-${var.environment}-${var.region}-container-benchmark-results"
}

resource "aws_s3_bucket_acl" "benchmark_results" {
  bucket = aws_s3_bucket.benchmark_results.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "benchmark_results" {
  bucket = aws_s3_bucket.benchmark_results.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
      }
    }
  }