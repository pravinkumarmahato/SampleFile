output "records" {
  description = "The 'aws_route53_record.record[*]' record(s)."
  value       = aws_route53_record.record[*]
}
